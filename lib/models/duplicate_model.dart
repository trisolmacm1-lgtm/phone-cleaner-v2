import 'package:photo_manager/photo_manager.dart';

class DuplicateGroup {
  final String hash;
  final List<AssetEntity> images;

  DuplicateGroup({required this.hash, required this.images});
}
