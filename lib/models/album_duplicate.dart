import 'duplicate_model.dart';

class AlbumWithDuplicates {
  final String name;
  final String id;
  final int totalImages;
  int duplicateCount;
  List<DuplicateGroup> duplicateGroups;
  String estimatedSize;

  AlbumWithDuplicates({
    required this.name,
    required this.id,
    required this.totalImages,
    required this.duplicateCount,
    required this.duplicateGroups,
    required this.estimatedSize,
  });
}
