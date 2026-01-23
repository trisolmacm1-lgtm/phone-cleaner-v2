import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/widgets/dialog.dart';
// Make sure you have your custom dialog widget from your other project.
import '../l10n/generated/app_localizations.dart';

/// A utility class to handle all permission-related logic for the iOS app.
class AppPermissions {
  /// Requests Photo Library permission for iOS.
  ///
  /// Returns `true` if permission is granted or limited.
  /// Returns `false` if denied.
  /// Shows a custom dialog and returns `false` if permanently denied.
  Future<bool> requestPhotosPermission(BuildContext context) async {
    final status = await Permission.photos.request();

    if (status.isGranted || status.isLimited) {
      // Permission is granted or user has selected a limited number of photos.
      // Both are considered success states for proceeding.
      return true;
    }

    if (status.isPermanentlyDenied) {
      // The user has permanently denied the permission.
      // We show a dialog to guide them to settings.
      showPhotoPermissionDialog(context);
      return false;
    }

    // The user has denied the permission for this session.
    return false;
  }

  /// Checks if Photo Library permission is already granted or limited.
  Future<bool> isPhotosPermissionGranted() async {
    final status = await Permission.photos.status;
    return status.isGranted || status.isLimited;
  }

  /// Shows a standardized dialog for permanently denied photo permissions.
  void showPhotoPermissionDialog(BuildContext context) {
    // This helper method makes it easy to show the dialog from anywhere.
    _showPermissionDialog(
      context: context,
      imagePath: 'assets/png/gallery_access.png', // Your image asset
      title: AppLocalizations.of(context)!.photoLibraryAccess,
      description: AppLocalizations.of(context)!.photoLibraryAccessDesc,
    );
  }

  /// A generic, private helper to show a permission dialog.
  /// This can be reused if you add more permissions later.
  void _showPermissionDialog({
    required BuildContext context,
    required String imagePath,
    required String title,
    required String description,
  }) {
    showDialog(
      context: context,
      builder: (context) => PermissionDialog(
        imagePath: imagePath,
        title: title,
        description: description,
        allowButtonText: AppLocalizations.of(context)!.openSettings,
        notNowButtonText: AppLocalizations.of(context)!.notNow,
        onAllowPressed: () async {
          Navigator.of(context).pop();
          // Opens the app's settings screen on the user's device.
          await openAppSettings();
        },
        onNotNowPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
