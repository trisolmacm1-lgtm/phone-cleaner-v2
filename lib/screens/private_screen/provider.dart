import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../core/routes.dart';
import '../../services/private_photos.dart';
import '../../services/private_storage.dart';

class PrivateProvider extends ChangeNotifier {
  final ImagePickerService photoService = ImagePickerService();
  final PrivateService storage = PrivateService();

  List<String> photoIds = [];
  bool isLoading = false;
  double progress = 0.0;
  final Set<String> selectedPhotoIds = {};

  bool _isLoading = false;
  bool get isLoadingVideo => _isLoading;
  bool get isAllSelected =>
      photoIds.isNotEmpty && selectedPhotoIds.length == photoIds.length;

  bool isSelected(String id) => selectedPhotoIds.contains(id);

  Future<void> addMultiplePhotos(BuildContext context) async {
    final files = await photoService.pickMultiplePhotos(context);
    if (files.isEmpty) return;

    isLoading = true;
    progress = 0.0;
    notifyListeners();

    for (int i = 0; i < files.length; i++) {
      final id = await storage.savePrivateImage(files[i]);
      if (id != null) {
        photoIds.add(id);
      }

      progress = (i + 1) / files.length;
      notifyListeners();
    }

    isLoading = false;
    progress = 0.0;
    notifyListeners();
  }

  void toggleSelectPhoto(String id) {
    if (selectedPhotoIds.contains(id)) {
      selectedPhotoIds.remove(id);
    } else {
      selectedPhotoIds.add(id);
    }
    notifyListeners();
  }

  void selectAll() {
    selectedPhotoIds.clear();
    selectedPhotoIds.addAll(photoIds);
    notifyListeners();
  }

  void clearSelection() {
    selectedPhotoIds.clear();
    notifyListeners();
  }

  void toggleSelectAll() {
    if (isAllSelected) {
      clearSelection();
    } else {
      selectAll();
    }
  }

  Future<void> loadPhotos() async {
    photoIds = await storage.loadAllImages();
    notifyListeners();
  }

  Future<void> deletePhoto(String id) async {
    await storage.deleteImage(id);
    photoIds.remove(id);
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<File?> getThumbnail(String id) => storage.getThumbnail(id);
  Future<File?> getFullImage(String id) => storage.getFullImage(id);

  Future<void> pickVideo(BuildContext context) async {
    try {
      _setLoading(true);

      final picker = ImagePicker();
      final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

      if (pickedFile != null) {
        final videoFile = File(pickedFile.path);

        // generate thumbnail
        final thumbBytes = await VideoThumbnail.thumbnailData(
          video: videoFile.path,
          imageFormat: ImageFormat.PNG,
          maxHeight: 200,
          quality: 95,
        );

        log("videoPath: ${videoFile.path}");

        if (context.mounted) {
          context.push(
            AppRouter.compression,
            extra: {'video': videoFile.path, 'thumb': thumbBytes},
          );
        }
      }
    } catch (e, stack) {
      log("Error picking video: $e");
      log("Stack trace: $stack");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Try with another video"),
            backgroundColor: Colors.blue,
            duration: Duration(milliseconds: 800),
          ),
        );
      }
    } finally {
      _setLoading(false);
    }
  }
}
