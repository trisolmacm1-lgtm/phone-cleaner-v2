import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

class DownloadSuccessDialog extends StatelessWidget {
  final Uint8List thumbnailBytes;
  final VoidCallback onNextVideo;
  final String? title;
  final String? subtitle;
  final VoidCallback onDone;
  final Image? image; // ✨ Added optional Image parameter

  const DownloadSuccessDialog({
    super.key,
    required this.thumbnailBytes,
    required this.onNextVideo,
    required this.onDone,
    this.image,
    this.title = "Saved Successfully",
    this.subtitle = "Your compressed video has been downloaded successfully.",
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Use provided image or fallback to thumbnailBytes
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              // ✨ Conditional logic added here
              child:
                  image ??
                  Image.memory(
                    thumbnailBytes,
                    height: 140,
                    width: 140,
                    fit: BoxFit.cover,
                  ),
            ),
            const SizedBox(height: 20),
            Text(
              title!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 24),

            // 🟦 Compressed Next Video Button
            ElevatedButton(
              onPressed: onNextVideo,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F62FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(
                image == null
                    ? localizations.compressedNextVideo
                    : localizations.done,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ⚪ Done Button
            if (image == null)
              ElevatedButton(
                onPressed: onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3F4F6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text(
                  localizations.done,
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
