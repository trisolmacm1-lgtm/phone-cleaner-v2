import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_cleaner_2/core/routes.dart';
import 'package:video_compress/video_compress.dart';

import '../../core/widgets/app_bar.dart';
import '../../core/widgets/gradient_button.dart';
import '../../l10n/generated/app_localizations.dart';

class CompressionScreen extends StatefulWidget {
  final String videoPath;
  final Uint8List thumbBytes;

  const CompressionScreen({
    super.key,
    required this.videoPath,
    required this.thumbBytes,
  });

  @override
  _CompressionScreenState createState() => _CompressionScreenState();
}

class _CompressionScreenState extends State<CompressionScreen> {
  int _selectedIndex = 1;
  bool _isCompressing = false;

  // ❌ The compressionOptions list has been moved from here...

  Future<void> _compressVideo() async {
    setState(() => _isCompressing = true);

    // Get localizations once to use in the catch block if needed
    final localizations = AppLocalizations.of(context)!;

    try {
      // --- CORRECTED LOGIC ---
      // This now correctly maps the UI selection to the compression quality.
      final quality = _selectedIndex == 0
          ? VideoQuality
                .Res960x540Quality // 👈 FIXED: Basic Compression is now Highest Quality
          : _selectedIndex == 1
          ? VideoQuality
                .MediumQuality // 👈 This remains Medium
          : VideoQuality
                .LowQuality; // 👈 FIXED: Strong Compression is now explicitly Low

      debugPrint(
        "⏳ Compressing with quality: $quality (Index: $_selectedIndex)",
      );

      final info = await VideoCompress.compressVideo(
        widget.videoPath,
        quality: quality,
        deleteOrigin: false,
        includeAudio: true,
      );

      if (info != null && mounted) {
        final compressedSize = File(info.path!).lengthSync();
        debugPrint("✅ Compression success: ${info.path}");

        context.push(
          AppRouter.videoResult,
          extra: {
            'compressedPath': info.path!,
            'compressedSize': compressedSize,
          },
        );
      }
    } catch (e) {
      debugPrint("❌ Compression error: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Compressed Failed")));
      }
    } finally {
      if (mounted) setState(() => _isCompressing = false);
    }
  }

  @override
  void dispose() {
    VideoCompress.cancelCompression();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // ✅ ...to inside the build method, so it can access localizations.
    final List<Map<String, String>> compressionOptions = [
      {
        'title': localizations.basicCompression, // 👈 LOCALIZED
        'description': localizations.mediumSizeHighQuality, // 👈 LOCALIZED
      },
      {
        'title': localizations.mediumCompression, // 👈 LOCALIZED
        'description': localizations.mediumSizeHighQuality, // 👈 LOCALIZED
      },
      {
        'title': localizations.strongCompression, // 👈 LOCALIZED
        'description': localizations.smallSizeBestQuality, // 👈 LOCALIZED
      },
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: localizations.compress,
        showBackButton: true,
        showActionButton: true,
        actionIcon: "assets/svg/ic_premium.svg",
        onActionTap: () {
          context.push(AppRouter.premium);
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Video thumbnail preview
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  // image: AssetImage('assets/png/border_video.png'),
                  image: MemoryImage(widget.thumbBytes),
                  fit: BoxFit.fill,
                ),
              ),
              // child: SizedBox(
              //   child: Image.memory(widget.thumbBytes, fit: BoxFit.fill),
              // ),
            ),
            const SizedBox(height: 20),

            // Compression options
            Expanded(
              child: ListView.builder(
                itemCount: compressionOptions.length,
                itemBuilder: (context, index) {
                  final option = compressionOptions[index];
                  final isSelected = _selectedIndex == index;

                  return GestureDetector(
                    onTap: _isCompressing
                        ? null
                        : () => setState(() => _selectedIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xff292B2B),
                        borderRadius: BorderRadius.circular(20),
                        // border: isSelected
                        //     ? Border.all(
                        //         color: const Color(0xFF586AFC),
                        //         width: 2,
                        //       )
                        //     : null,
                      ),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          isSelected
                              ? SvgPicture.asset(
                                  'assets/svg/check_circle.svg',
                                  width: 24,
                                  height: 24,
                                  colorFilter: ColorFilter.mode(
                                    Theme.of(context).primaryColor,
                                    BlendMode.srcIn,
                                  ),
                                )
                              : SvgPicture.asset(
                                  'assets/svg/circle.svg',
                                  width: 24,
                                  height: 24,
                                  colorFilter: ColorFilter.mode(
                                    Theme.of(context).primaryColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                          SizedBox(width: 18),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option['title']!,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Gilroy',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                option['description']!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Gilroy',
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Continue button or loader
            _isCompressing
                ? Column(
                    children: [
                      const SizedBox(height: 10),
                      CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        // This was already localized correctly
                        AppLocalizations.of(context)!.compressingVideo,
                        style: const TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  )
                : GradientButton(
                    text: localizations.continuee,
                    onPressed: _compressVideo,
                    borderRadius: 42,
                  ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
