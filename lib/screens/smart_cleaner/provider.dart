import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:phone_cleaner_2/screens/duplicate_videos_screen/provider.dart';
import 'package:provider/provider.dart';

import '../../models/media_item.dart';
import '../../services/storage_permission.dart';
import '../../services/storage_service.dart';

class StorageProvider extends ChangeNotifier {
  final StorageService _service = StorageService();
  final AppPermissions _permissions = AppPermissions();

  bool _isPermissionGranted = false;
  bool get isPermissionGranted => _isPermissionGranted;

  double total = 0;
  double used = 0;
  double free = 0;

  bool isLoading = false;
  bool isCalculatingSizes = false;
  bool isCleaning = false;

  List<MediaItem> photos = [];
  List<MediaItem> videos = [];
  List<Contact> contacts = [];

  StorageProvider() {
    _checkInitialPermission();
    loadStorageDetails();
    loadMedia();
    loadContacts();
  }

  Future<void> _checkInitialPermission() async {
    _isPermissionGranted = await _permissions.isPhotosPermissionGranted();
    if (_isPermissionGranted) {
      loadMedia();
    }
    notifyListeners();
  }

  /// Public method for the UI to call.
  /// It now uses the AppPermissions class.
  Future<void> requestPermission(BuildContext context) async {
    final bool permissionGranted = await _permissions.requestPhotosPermission(
      context,
    );

    if (permissionGranted) {
      _isPermissionGranted = true;
      loadMedia();
    } else {
      _isPermissionGranted = false;
    }

    notifyListeners();
  }

  /// 🔹 Load storage stats
  Future<void> loadStorageDetails() async {
    final data = await _service.getStorageDetails();
    total = data['total'] ?? 0;
    used = data['used'] ?? 0;
    free = data['free'] ?? 0;
    notifyListeners();
  }

  /// 🔹 Load media
  Future<void> loadMedia({bool withSizes = false}) async {
    isLoading = true;
    notifyListeners();

    final results = await Future.wait([
      _service.getPhotos(limit: 10000, page: 0, withSize: withSizes),
      _service.getVideos(limit: 2000, page: 0, withSize: withSizes),
    ]);

    photos = results[0];
    videos = results[1];

    isLoading = false;
    notifyListeners();
  }

  /// 🔹 Load contacts from phone
  Future<void> loadContacts() async {
    final permission = await FlutterContacts.requestPermission();
    if (!permission) return;

    contacts = await FlutterContacts.getContacts(withProperties: true);

    notifyListeners();
  }

  /// 🔹 Delete all contacts
  Future<void> deleteAllContacts() async {
    try {
      for (final contact in contacts) {
        await contact.delete();
      }
      contacts.clear();
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to delete contacts: $e");
    }
  }

  /// 🔹 Smart Clean - Delete all
  Future<void> smartCleanAll(BuildContext context) async {
    if (isCleaning) return;
    isCleaning = true;
    notifyListeners();
    final provider1 = Provider.of<DuplicateVideoFinderProvider>(
      context,
      listen: false,
    );
    final provider2 = Provider.of<DuplicateVideoFinderProvider>(
      context,
      listen: false,
    );
    try {
      await _service.deleteAllImages(photos);
      await _service.deleteAllVideos(videos);
      await deleteAllContacts();

      photos.clear();
      videos.clear();
      await loadStorageDetails();

      await provider1
          .startScan(); // Notify duplicate finder to refresh if needed and
      await provider2.startScan();

      /// call that functon
      notifyListeners();
    } catch (e) {
      debugPrint("Smart clean failed: $e");
    }

    isCleaning = false;
    notifyListeners();
  }

  /// 🔹 Compute sizes lazily for PHOTOS only (batch updates)
  Future<void> computePhotoSizes({int batchSize = 10}) async {
    if (photos.isEmpty) return;
    isCalculatingSizes = true;
    notifyListeners();

    for (int i = 0; i < photos.length; i += batchSize) {
      final batch = photos.skip(i).take(batchSize);
      final updatedBatch = await Future.wait(
        batch.map((m) async {
          final size = await _service.getAssetFileSize(m.asset);
          return MediaItem(
            id: m.id,
            asset: m.asset,
            sizeInBytes: size,
            isVideo: m.isVideo,
          );
        }),
      );

      // Update items progressively
      for (var item in updatedBatch) {
        final index = photos.indexWhere((x) => x.id == item.id);
        if (index != -1) photos[index] = item;
      }

      notifyListeners(); // Refresh UI for partial update
    }

    isCalculatingSizes = false;
    notifyListeners();
  }

  /// 🔹 Compute sizes lazily for VIDEOS only (batch updates)
  Future<void> computeVideoSizes({int batchSize = 10}) async {
    if (videos.isEmpty) return;
    isCalculatingSizes = true;
    notifyListeners();

    for (int i = 0; i < videos.length; i += batchSize) {
      final batch = videos.skip(i).take(batchSize);
      final updatedBatch = await Future.wait(
        batch.map((m) async {
          final size = await _service.getAssetFileSize(m.asset);
          return MediaItem(
            id: m.id,
            asset: m.asset,
            sizeInBytes: size,
            isVideo: m.isVideo,
          );
        }),
      );

      for (var item in updatedBatch) {
        final index = videos.indexWhere((x) => x.id == item.id);
        if (index != -1) videos[index] = item;
      }

      notifyListeners();
    }

    isCalculatingSizes = false;
    notifyListeners();
  }

  /// 🔹 Compute sizes for both sections simultaneously
  Future<void> computeAllSizes({int batchSize = 10}) async {
    isCalculatingSizes = true;
    notifyListeners();

    await Future.wait([
      computePhotoSizes(batchSize: batchSize),
      computeVideoSizes(batchSize: batchSize),
    ]);

    isCalculatingSizes = false;
    notifyListeners();
  }

  /// 🔹 Helpers for UI
  int totalPhotoBytes() => photos.fold(0, (p, e) => p + e.sizeInBytes);
  int totalVideoBytes() => videos.fold(0, (p, e) => p + e.sizeInBytes);

  String formatBytes(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    double size = bytes.toDouble();
    int i = 0;
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }

  String get totalFormatted => "3";
  String get usedFormatted => "23";
  String get freeFormatted => "sd";
}
