import 'dart:typed_data';
import 'package:photo_manager/photo_manager.dart';

class MediaItem {
  final String id;
  final AssetEntity asset;
  final int sizeInBytes; // 0 means unknown / not yet fetched
  final bool isVideo;

  MediaItem({
    required this.id,
    required this.asset,
    this.sizeInBytes = 0,
    required this.isVideo,
  });

  /// Helper to get a thumbnail (used by UI)
  Future<Uint8List?> getThumbnail({int width = 200, int height = 200}) {
    return asset.thumbnailDataWithSize(ThumbnailSize(width, height));
  }
}
