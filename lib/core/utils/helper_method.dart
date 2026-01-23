import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_cleaner_2/core/utils/colors.dart';
import 'package:phone_cleaner_2/core/utils/responsive_sizer.dart';
import 'package:phone_cleaner_2/core/widgets/gradient_button.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/generated/app_localizations.dart';
import '../widgets/delete_dialog.dart';
import '../widgets/download_dialog.dart';

class UrlLauncher {
  static Future<void> launchTerms(
    BuildContext context,
    String urlString,
  ) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // Handle error
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Could not launch URL")));
      }
    }
  }
}

class ClickDelay {
  static bool _isClicked = false;

  static Future<void> run(VoidCallback action) async {
    if (_isClicked) return; // Ignore if already running
    _isClicked = true;

    try {
      action();
    } finally {
      // Allow clicks again after a short delay
      Future.delayed(const Duration(milliseconds: 800), () {
        _isClicked = false;
      });
    }
  }
}

void deleteDialogConfirmation(
  BuildContext context,
  void Function() onDeletePressed,
) {
  showDialog(
    context: context,
    builder: (context) {
      return CustomActionDialog(
        buttonText: AppLocalizations.of(context)!.delete,
        iconPath: 'assets/svg/ic_delete.svg',
        title: 'Deletion !',
        subtitle: AppLocalizations.of(context)!.deleteConfirm,
        onPressed: () => onDeletePressed(),
      );
    },
  );
}

void deleteDialogConfirmationNew(
  BuildContext context,
  void Function() onDeletePressed,
) {
  showDialog(
    context: context,
    builder: (context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: AlertDialog(
          contentPadding: EdgeInsets.zero,
          backgroundColor: AppColors.bgColor,
          elevation: 0,

          content: SizedBox(
            width: 400.w,
            height: 350.h, // <-- give fixed height so Positioned works
            child: Stack(
              children: [
                /// BACKGROUND IMAGE (must be first!)
                Positioned.fill(
                  child: Image.asset(
                    'assets/png/dialog_bg.png',
                    fit: BoxFit.fill,
                  ),
                ),
                Positioned(
                  top: 40.h,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 100.h,
                    width: 100.h,
                    padding: EdgeInsets.all(14.adaptSize),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),

                    child: SvgPicture.asset('assets/svg/btn_delete.svg'),
                  ),
                ),

                /// TITLE
                Positioned(
                  top: 180.h,
                  left: 0,
                  right: 0,
                  child: Text(
                    AppLocalizations.of(context)!.delete,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.fSize,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                /// SUBTEXT
                Positioned(
                  top: 210.h,
                  left: 0,
                  right: 0,
                  child: Text(
                    AppLocalizations.of(context)!.deleteConfirm,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13.fSize,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                /// DELETE BUTTON
                Positioned(
                  bottom: 40,
                  left: 18,
                  right: 18,
                  child: CustomButtonWidget(
                    text: AppLocalizations.of(context)!.delete,
                    onPressed: () {
                      // Navigator.pop(context);
                      onDeletePressed();
                    },
                    borderRadius: 30,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFC94A), Color(0xFFFF9F1C)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<void> showDownloadSuccessDialogNew({
  required BuildContext context,
  required Uint8List thumbnailBytes,
  required String title,
  required String subtitle,
  required VoidCallback onNextVideo,
  required VoidCallback onDone,
  Image? image, // The optional image widget
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: AlertDialog(
          contentPadding: EdgeInsets.zero,
          backgroundColor: AppColors.bgColor,
          elevation: 0,

          content: SizedBox(
            width: 400.w,
            height: 350.h, // <-- give fixed height so Positioned works
            child: Stack(
              children: [
                /// BACKGROUND IMAGE (must be first!)
                Positioned.fill(
                  child: Image.asset(
                    'assets/png/dialog_bg.png',
                    fit: BoxFit.fill,
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 90.h,
                    width: 90.w,
                    margin: EdgeInsets.only(top: 30.h),
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    child: Stack(
                      children: [
                        Image.asset(
                          'assets/png/success.png',
                          color: Theme.of(context).primaryColor,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Image.asset('assets/png/tick.png', scale: 2),
                        ),
                      ],
                    ),
                  ),
                ),

                /// TITLE
                Positioned(
                  top: 150.h,
                  left: 0,
                  right: 0,
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.fSize,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                /// SUBTEXT
                Positioned(
                  top: 190.h,
                  left: 0,
                  right: 0,
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13.fSize,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                /// DELETE BUTTON
                Positioned(
                  bottom: 40,
                  left: 18,
                  right: 18,
                  child: CustomButtonWidget(
                    text: AppLocalizations.of(context)!.done,
                    onPressed: () {
                      context.pop();
                      onDone();
                    },
                    borderRadius: 30,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFC94A), Color(0xFFFF9F1C)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<void> showDownloadSuccessDialog({
  required BuildContext context,
  required Uint8List thumbnailBytes,
  required String title,
  required String subtitle,
  required VoidCallback onNextVideo,
  required VoidCallback onDone,
  Image? image, // The optional image widget
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return DownloadSuccessDialog(
        thumbnailBytes: thumbnailBytes,
        title: title,
        subtitle: subtitle,
        onNextVideo: () {
          context.pop();
          onNextVideo();
        },
        onDone: () {
          context.pop();
          onDone();
        },
        image: image,
      );
    },
  );
}
