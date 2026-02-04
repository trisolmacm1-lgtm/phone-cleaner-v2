import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../models/album_duplicate.dart';
import '../../../models/duplicate_model.dart';

class DuplicateVideoFinderProvider extends ChangeNotifier {
  // DuplicateVideoFinderProvider({})
  bool isLoading = false;
  bool isScanning = false;
  double scanProgress = 0.0;
  List<AlbumWithDuplicates> albums = [];

  // ✅ New variable for the total size of all duplicates across all albums (in MB)
  double totalEstimatedDuplicateSizeMB = 0.0;

  bool _hasScannedOnce = false;

  // =========================================================
  // ✅ STATIC UTILITY FUNCTION TO FORMAT SIZE (MB/GB/TB)
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

  Future<void> startScan() async {
    // if (_hasScannedOnce) return;
    // _hasScannedOnce = true;

    isLoading = true;
    isScanning = true;
    scanProgress = 0.0;
    albums = [];
    // ✅ Reset total size
    totalEstimatedDuplicateSizeMB = 0.0;
    notifyListeners();

    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.isAuth) {
      isLoading = false;
      isScanning = false;
      notifyListeners();
      return;
    }

    try {
      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.video,
      );
      int processedPaths = 0;

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
          final Uint8List? thumbData = await asset.thumbnailDataWithSize(
            const ThumbnailSize(64, 64),
          );
          if (thumbData != null) {
            final hash = md5.convert(thumbData).toString();
            hashMap.putIfAbsent(hash, () => []).add(asset);
          }

          scanProgress = (processedPaths + (i / assets.length)) / paths.length;
          notifyListeners();
        }

        // Build duplicate groups
        List<DuplicateGroup> duplicateGroups = [];
        int duplicateCount = 0;

        hashMap.forEach((hash, vids) {
          if (vids.length > 1) {
            duplicateGroups.add(DuplicateGroup(hash: hash, images: vids));
            duplicateCount += vids.length;
          }
        });

        if (duplicateGroups.isNotEmpty) {
          double avgSizePerVideo = 10.0; // approx MB

          // Calculate the estimated size for this album in MB
          double albumEstimatedSizeMB = duplicateCount * avgSizePerVideo;

          // ✅ Use the new function to format the size string
          String estimatedSizeString = _formatSize(albumEstimatedSizeMB);

          // ✅ Add to the total estimated size
          totalEstimatedDuplicateSizeMB += albumEstimatedSizeMB;

          final newAlbum = AlbumWithDuplicates(
            name: path.name,
            id: path.id,
            totalImages: assets.length,
            duplicateCount: duplicateCount,
            duplicateGroups: duplicateGroups,
            estimatedSize: estimatedSizeString, // ✅ Updated format
          );

          albums.add(newAlbum);
        }

        processedPaths++;
        scanProgress = processedPaths / paths.length;
        notifyListeners();
      }

      isLoading = false;
      isScanning = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      isScanning = false;
      notifyListeners();
    }
  }

  void removeDeletedAssets(List<String> deletedIds) {
    bool changed = false;
    // ✅ Initialize new total size accumulator
    double newTotalEstimatedSizeMB = 0.0;

    for (var album in albums) {
      for (var group in album.duplicateGroups) {
        final beforeCount = group.images.length;
        group.images.removeWhere((asset) => deletedIds.contains(asset.id));
        if (group.images.length != beforeCount) changed = true;
      }

      album.duplicateGroups.removeWhere((group) => group.images.length < 2);

      int newDuplicateCount = 0;
      for (var group in album.duplicateGroups) {
        newDuplicateCount += group.images.length;
      }

      album.duplicateCount = newDuplicateCount;

      double avgSizePerVideo = 50.0;
      double albumEstimatedSizeMB = album.duplicateCount * avgSizePerVideo;

      // ✅ Use the new function to format the size string
      album.estimatedSize = _formatSize(albumEstimatedSizeMB);

      // ✅ Accumulate the new total estimated size
      newTotalEstimatedSizeMB += albumEstimatedSizeMB;
    }

    // ✅ Update the class variable
    totalEstimatedDuplicateSizeMB = newTotalEstimatedSizeMB;

    albums.removeWhere((album) => album.duplicateGroups.isEmpty);

    if (changed) notifyListeners();
  }

  void resetScan() {
    _hasScannedOnce = false;
    albums.clear();
    scanProgress = 0.0;
    // ✅ Reset total size on full reset
    totalEstimatedDuplicateSizeMB = 0.0;
    notifyListeners();
  }
}
