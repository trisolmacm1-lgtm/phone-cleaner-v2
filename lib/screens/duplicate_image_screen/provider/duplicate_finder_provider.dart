import 'dart:developer';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../models/album_duplicate.dart';
import '../../../models/duplicate_model.dart';
import '../../../models/media_item.dart';
import '../../../services/storage_service.dart';

class DuplicateFinderProvider extends ChangeNotifier {

  bool isLoading = false;
  bool isScanning = false;
  double scanProgress = 0.0;
  List<AlbumWithDuplicates> albums = [];
  final StorageService _service = StorageService();

  // ✅ New variable for the total size of all duplicates across all albums
  double totalEstimatedDuplicateSizeMB = 0.0;

  bool _hasScannedOnce = false;

  Future<void> startScan() async {
    print('_hasScannedOnce $_hasScannedOnce');
    // if (_hasScannedOnce) return;
    // _hasScannedOnce = true;

    isLoading = true;
    isScanning = true;
    scanProgress = 0.0;
    albums = [];
    totalEstimatedDuplicateSizeMB =
        0.0; // This will now be the actual total size
    notifyListeners();

    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    print('ps $ps');
    if (!ps.isAuth) {
      isLoading = false;
      isScanning = false;
      notifyListeners();
      return;
    }

    try {
      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );
      int processedPaths = 0;
      log('paths $paths');
      for (var path in paths) {
        final int assetCount = await path.assetCountAsync;
        if (assetCount <= 0) continue;

        final List<AssetEntity> assets = await path.getAssetListRange(
          start: 0,
          end: assetCount,
        );
        if (assets.isEmpty) continue;

        Map<String, List<AssetEntity>> hashMap = {};

        for (int i = 0; i < assets.length; i++) {
          final asset = assets[i];
          final Uint8List? imageData = await asset.thumbnailDataWithSize(
            const ThumbnailSize(64, 64),
          );
          if (imageData != null) {
            final hash = md5.convert(imageData).toString();
            hashMap.putIfAbsent(hash, () => []).add(asset);
          }

          scanProgress = (processedPaths + (i / assets.length)) / paths.length;
          notifyListeners();
        }

        // --- 🚀 START: MODIFIED SECTION ---

        // 1. Find groups with more than one image (the duplicates)
        final duplicateGroupsAssets = hashMap.values
            .where((imgs) => imgs.length > 1)
            .toList();

        if (duplicateGroupsAssets.isNotEmpty) {
          // 2. Create a single flat list of all duplicate AssetEntity objects
          final List<AssetEntity> allDuplicateAssets = duplicateGroupsAssets
              .expand((group) => group)
              .toList();

          // 3. Get the actual sizes for all duplicates in this album efficiently
          final List<MediaItem> duplicateMediaItems = await _service
              .computeMediaSizes(
                allDuplicateAssets,
                isVideo: false, // Assuming these are images
              );

          // 5. Re-build the duplicate groups, but now with real size info
          List<DuplicateGroup> duplicateGroups = [];
          for (var groupOfAssets in duplicateGroupsAssets) {
            // You might want to update your DuplicateGroup model to store MediaItems or sizes
            duplicateGroups.add(
              DuplicateGroup(
                hash: 'some_hash', // You'll need to associate the hash again
                images: groupOfAssets,
                // You can also calculate total size per group here
                // sizeInBytes: groupOfAssets.fold(0, (sum, asset) => sum + (sizeMap[asset.id] ?? 0)),
              ),
            );
          }

          // 6. Calculate the total size of all duplicates in this album
          final int albumDuplicateSizeInBytes = duplicateMediaItems.fold(
            0,
            (sum, item) => sum + item.sizeInBytes,
          );
          final double albumDuplicateSizeMB =
              albumDuplicateSizeInBytes / (1024 * 1024);

          // Update the grand total
          totalEstimatedDuplicateSizeMB += albumDuplicateSizeMB;

          final newAlbum = AlbumWithDuplicates(
            name: path.name,
            id: path.id,
            totalImages: assets.length,
            duplicateCount: allDuplicateAssets.length,
            duplicateGroups: duplicateGroups,
            estimatedSize: _formatSize(
              albumDuplicateSizeMB,
            ), // Use the actual calculated size
          );

          albums.add(newAlbum);
        }

        // --- 🚀 END: MODIFIED SECTION ---

        processedPaths++;
        scanProgress = processedPaths / paths.length;
        notifyListeners();
      }

      isLoading = false;
      isScanning = false;
      notifyListeners();
    } catch (e) {
      // Consider logging the error: print(e);
      isLoading = false;
      isScanning = false;
      notifyListeners();
    }
  }

  void removeDeletedAssets(List<String> deletedIds) {
    bool changed = false;
    // ✅ Reset total size before recalculating
    double newTotalEstimatedSizeMB = 0.0;

    for (var album in albums) {
      for (var group in album.duplicateGroups) {
        final beforeCount = group.images.length;
        group.images.removeWhere((asset) => deletedIds.contains(asset.id));
        if (group.images.length != beforeCount) changed = true;
      }

      // Remove groups that are no longer duplicates
      album.duplicateGroups.removeWhere((group) => group.images.length < 2);

      // Recalculate duplicate count and estimated size
      int newDuplicateCount = 0;
      for (var group in album.duplicateGroups) {
        newDuplicateCount += group.images.length;
      }

      album.duplicateCount = newDuplicateCount;

      // Example size calculation (approx 2.5MB per image)
      double avgSizePerImage = 2.5;
      double albumEstimatedSizeMB = album.duplicateCount * avgSizePerImage;

      // ✅ Use the new function to format the size string
      album.estimatedSize = _formatSize(albumEstimatedSizeMB);

      newTotalEstimatedSizeMB += albumEstimatedSizeMB;
    }

    // ✅ Update the class variable
    totalEstimatedDuplicateSizeMB = newTotalEstimatedSizeMB;

    // Remove empty albums
    albums.removeWhere((album) => album.duplicateGroups.isEmpty);

    if (changed) {
      notifyListeners();
    }
  }

  // =========================================================
  // ✅ NEW STATIC UTILITY FUNCTION TO FORMAT SIZE
  // =========================================================
  static String _formatSize(double sizeMB) {
    if (sizeMB < 1024) {
      // MB (less than 1 GB)
      return '${sizeMB.toStringAsFixed(1)} MB';
    } else if (sizeMB < 1024 * 1024) {
      // GB (less than 1 TB)
      double sizeGB = sizeMB / 1024;
      return '${sizeGB.toStringAsFixed(2)} GB';
    } else {
      // TB or larger
      double sizeTB = sizeMB / (1024 * 1024);
      return '${sizeTB.toStringAsFixed(3)} TB';
    }
  }

  // =========================================================
  // Getter for formatted total size
  // =========================================================
  String get totalEstimatedDuplicateSizeFormatted {
    return _formatSize(totalEstimatedDuplicateSizeMB);
  }

  void resetScan() {
    _hasScannedOnce = false;
    albums.clear();
    scanProgress = 0.0;
    // ✅ Reset the total size on full reset
    totalEstimatedDuplicateSizeMB = 0.0;
    notifyListeners();
  }
}
