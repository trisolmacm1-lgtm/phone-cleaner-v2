import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_cleaner_2/core/widgets/gradient_button.dart';
import 'package:phone_cleaner_2/screens/private_screen/provider.dart';
import 'package:provider/provider.dart';

import '../../core/utils/helper_method.dart';
import '../../core/widgets/app_bar.dart';
import '../../l10n/generated/app_localizations.dart';

class ImageDisplayScreen extends StatelessWidget {
  final String id;
  final File image;

  const ImageDisplayScreen({super.key, required this.id, required this.image});

  Future<void> _saveImage(BuildContext context) async {
    try {
      await GallerySaver.saveImage(image.path);
      showDownloadSuccessDialogNew(
        context: context,
        title: AppLocalizations.of(context)!.downloadSuccess,
        subtitle: AppLocalizations.of(context)!.imageDownloaded,
        onNextVideo: () => print("Next Video Tapped!"),
        onDone: () => Navigator.pop(context),
        // Provide a custom Image widget.
        image: Image.asset(
          image.path,
          height: 140,
          width: 140,
          fit: BoxFit.cover,
        ),
        thumbnailBytes: Uint8List(0),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Save to gallery failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final gallery = Provider.of<PrivateProvider>(context, listen: false);
    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.private,
        showBackButton: true,
        showActionButton: true,
        actionIcon: "assets/svg/ic_premium.svg",
        onActionTap: () {},
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 🖼️ Image container with rounded corners
            Expanded(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(image),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  // child: Image.file(
                  //   image,
                  //   fit: BoxFit.cover,
                  //   width: double.infinity,
                  // ),
                ),
              ),
            ),

            // 🔘 Two Buttons stacked vertically
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                children: [
                  GradientButton(
                    text: AppLocalizations.of(context)!.saveImage,
                    onPressed: () {
                      _saveImage(context);
                    },
                  ),

                  const SizedBox(height: 16),
                  GradientButton(
                    text: AppLocalizations.of(context)!.deleteImage,
                    // gradientColors: [
                    //   const Color(0xFFD7D3D3),
                    //   const Color(0xFFD7D3D3),
                    // ],
                    onPressed: () {
                      print('object');
                      deleteDialogConfirmationNew(context, () async {
                        print('object2');
                        await gallery.deletePhoto(id);
                        context.pop();
                        context.pop();
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
