import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<List<File>> pickMultiplePhotos(BuildContext context) async {
    // Pick multiple images
    final List<XFile>? pickedFiles = await _picker.pickMultiImage(
      limit: 10, // optional: limit the number of selected images
    );

    if (pickedFiles == null || pickedFiles.isEmpty) return [];

    // Convert XFile to File
    final files = pickedFiles.map((xfile) => File(xfile.path)).toList();
    return files;
  }
}