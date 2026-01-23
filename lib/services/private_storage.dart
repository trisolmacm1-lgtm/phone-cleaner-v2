import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class PrivateService {

  Future<File?> getFullImage(String baseName) async {
    try {
      final dir = await _getAppDir();
      final imagePath = "${dir.path}/$baseName.jpg";
      final file = File(imagePath);

      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      print("Error getting full image: $e");
      return null;
    }
  }
  Future<String?> savePrivateImage(File file) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final baseName = DateTime.now().millisecondsSinceEpoch.toString();
      final fullPath = "${dir.path}/$baseName.jpg";
      final thumbPath = "${dir.path}/${baseName}_thumb.jpg";

      // Copy full image to app storage
      final bytes = await file.readAsBytes();
      await File(fullPath).writeAsBytes(bytes);

      // Create and save thumbnail
      final decoded = img.decodeImage(bytes);
      if (decoded != null) {
        final thumbnail = img.copyResize(decoded, width: 200);
        final thumbBytes = Uint8List.fromList(img.encodeJpg(thumbnail, quality: 85));
        await File(thumbPath).writeAsBytes(thumbBytes);
      }

      return baseName; // photo id
    } catch (e) {
      print("Error saving image: $e");
      return null;
    }
  }

  Future<File?> getThumbnail(String baseName) async {
    try {
      final dir = await _getAppDir();
      final thumbPath = "${dir.path}/${baseName}_thumb.jpg";
      final file = File(thumbPath);

      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      print("Error getting thumbnail: $e");
      return null;
    }
  }

  Future<List<String>> loadAllImages() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final files = Directory(dir.path)
          .listSync()
          .where((f) => f.path.endsWith(".jpg") && !f.path.contains("thumb"))
          .map((f) => f.uri.pathSegments.last.replaceAll(".jpg", ""))
          .toList();
      return files;
    } catch (e) {
      print("Error loading images: $e");
      return [];
    }
  }

  Future<void> deleteImage(String baseName) async {
    try {
      final dir = await _getAppDir();
      final fullPath = "${dir.path}/$baseName.jpg";
      final thumbPath = "${dir.path}/${baseName}_thumb.jpg";

      final fullFile = File(fullPath);
      final thumbFile = File(thumbPath);

      if (await fullFile.exists()) {
        await fullFile.delete();
      }

      if (await thumbFile.exists()) {
        await thumbFile.delete();
      }
    } catch (e) {
      print("Error deleting image: $e");
    }
  }

  Future<Directory> _getAppDir() async {
    return await getApplicationDocumentsDirectory();
  }
}