import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'package:disk_space/disk_space.dart';
import '../models/media_item.dart';

class StorageService {
  /// 🔹 Fetch device storage info (GB)
  Future<Map<String, double>> getStorageDetails() async {
    double? total = await DiskSpace.getTotalDiskSpace;
    double? free = await DiskSpace.getFreeDiskSpace;
    double used = (total ?? 0) - (free ?? 0);

    return {
      'total': (total! / 1024),
      'used': used / 1024,
      'free': (free! / 1024),
    };
  }

  /// 🔹 Fetch photos (paginated)
  Future<List<MediaItem>> getPhotos({
    int limit = 50,
    int page = 0,
    bool withSize = false,
  }) async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.isAuth) return [];

    final albums = await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: RequestType.image,
    );
    if (albums.isEmpty) return [];

    final assets = await albums.first.getAssetListPaged(
      page: page,
      size: limit,
    );

    if (!withSize) {
      return assets
          .map(
            (e) =>
                MediaItem(id: e.id, asset: e, sizeInBytes: 0, isVideo: false),
          )
          .toList();
    }

    return computeMediaSizes(assets, isVideo: false);
  }

  /// 🔹 Fetch videos (paginated)
  Future<List<MediaItem>> getVideos({
    int limit = 50,
    int page = 0,
    bool withSize = false,
  }) async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.isAuth) return [];

    final albums = await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: RequestType.video,
    );
    if (albums.isEmpty) return [];

    final assets = await albums.first.getAssetListPaged(
      page: page,
      size: limit,
    );

    if (!withSize) {
      return assets
          .map(
            (e) => MediaItem(id: e.id, asset: e, sizeInBytes: 0, isVideo: true),
          )
          .toList();
    }

    return computeMediaSizes(assets, isVideo: true);
  }

  /// 🔹 Compute size for one asset
  Future<int> getAssetFileSize(AssetEntity asset) async {
    try {
      final File? file = await asset.originFile ?? await asset.file;
      return file != null ? await file.length() : 0;
    } catch (_) {
      return 0;
    }
  }

  /// 🔹 Compute media sizes in batches
  Future<List<MediaItem>> computeMediaSizes(
    List<AssetEntity> assets, {
    required bool isVideo,
    int batchSize = 10,
  }) async {
    final List<MediaItem> result = [];
    for (int i = 0; i < assets.length; i += batchSize) {
      final batch = assets.skip(i).take(batchSize);
      final batchResults = await Future.wait(
        batch.map((asset) async {
          final size = await getAssetFileSize(asset);
          return MediaItem(
            id: asset.id,
            asset: asset,
            sizeInBytes: size,
            isVideo: isVideo,
          );
        }),
      );
      result.addAll(batchResults);
    }
    return result;
  }

  // 🔹 DELETE FUNCTIONS

  /// Delete all images
  Future<void> deleteAllImages(List<MediaItem> photos) async {
    try {
      final assets = photos.map((e) => e.asset).toList();
      if (assets.isNotEmpty) {
        await PhotoManager.editor.deleteWithIds(
          assets.map((a) => a.id).toList(),
        );
      }
    } catch (e) {
      print("Error deleting images: $e");
    }
  }

  /// Delete all videos
  Future<void> deleteAllVideos(List<MediaItem> videos) async {
    try {
      final assets = videos.map((e) => e.asset).toList();
      if (assets.isNotEmpty) {
        await PhotoManager.editor.deleteWithIds(
          assets.map((a) => a.id).toList(),
        );
      }
    } catch (e) {
      print("Error deleting videos: $e");
    }
  }

}
