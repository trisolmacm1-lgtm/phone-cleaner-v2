import 'dart:math';
import 'dart:typed_data';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_cleaner_2/core/routes.dart';
import 'package:phone_cleaner_2/core/utils/helper_method.dart';
import 'package:phone_cleaner_2/core/utils/responsive_sizer.dart';
import 'package:phone_cleaner_2/core/widgets/gradient_button.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../l10n/generated/app_localizations.dart';
import '../paywall_screen/paywall_provider.dart';

class CompressResultScreen extends StatefulWidget {
  final String compressedPath;
  final int compressedSize;

  const CompressResultScreen({
    super.key,
    required this.compressedPath,
    required this.compressedSize,
  });

  @override
  State<CompressResultScreen> createState() => _CompressResultScreenState();
}

class _CompressResultScreenState extends State<CompressResultScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  bool _visible = false;
  bool _scaled = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    // Trigger animations sequentially
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => _visible = true);
      _confettiController.play();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() => _scaled = true);
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  String _formatBytes(int bytes, [int decimals = 2]) {
    if (bytes == 0) return "0 B";
    const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${sizes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final premium = Provider.of<PremiumProvider>(context);
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // 🎉 Confetti Celebration
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.05,
            numberOfParticles: 25,
            gravity: 0.4,
          ),

          // 🧱 Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: SvgPicture.asset(
                        "assets/svg/ic_back.svg",
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  // ✅ Animated Success Icon
                  // AnimatedScale(
                  //   scale: _scaled ? 1.0 : 0.6,
                  //   duration: const Duration(milliseconds: 500),
                  //   curve: Curves.easeOutBack,
                  //   child: AnimatedOpacity(
                  //     opacity: _visible ? 1.0 : 0.0,
                  //     duration: const Duration(milliseconds: 400),
                  //     child: Container(
                  //       width: 60,
                  //       height: 60,
                  //       decoration: BoxDecoration(
                  //         shape: BoxShape.circle,
                  //         border: Border.all(
                  //           color: AppColors.primaryColor,
                  //           width: 2,
                  //         ),
                  //       ),
                  //       child: Icon(
                  //         Icons.check,
                  //         color: AppColors.primaryColor,
                  //         size: 30,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 16),

                  // ✅ Animated Video Thumbnail Preview
                  AnimatedOpacity(
                    opacity: _visible ? 1 : 0,
                    duration: const Duration(milliseconds: 1000),
                    child: FutureBuilder<Uint8List?>(
                      future: VideoThumbnail.thumbnailData(
                        video: widget.compressedPath,
                        imageFormat: ImageFormat.PNG,
                        maxWidth: 400,
                        quality: 90,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(
                              snapshot.data!,
                              height: 280,
                              width: 250,
                              fit: BoxFit.cover,
                            ),
                          );
                        } else {
                          return Container(
                            height: 260,
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  // ✅ Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/svg/check_circle.svg',

                        colorFilter: ColorFilter.mode(
                          Theme.of(context).primaryColor,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: 10),
                      AnimatedOpacity(
                        opacity: _visible ? 1 : 0,
                        duration: const Duration(milliseconds: 600),
                        child: Text(
                          "${localizations.compressed} ${localizations.done}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // ✅ File Size
                  AnimatedOpacity(
                    opacity: _visible ? 1 : 0,
                    duration: const Duration(milliseconds: 800),
                    child: Text(
                      "${localizations.your_video_is} ${_formatBytes(widget.compressedSize)} ${localizations.smaller}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // const Spacer(),
                  SizedBox(height: 80.h),
                  // ✅ Upgrade Button
                  if (!Provider.of<PremiumProvider>(context).isSubscribe)
                    GradientButton(
                          iconPath: 'assets/svg/upgrade.svg',
                          borderRadius: 32,
                          text: localizations.upgrade,
                          onPressed: () {
                            context.push(AppRouter.premium);
                          },
                        )
                        .animate(
                          onPlay: (controller) =>
                              controller.repeat(reverse: true, period: 1000.ms),
                        )
                        .scale(
                          begin: const Offset(0.95, 0.95), // slightly smaller
                          end: const Offset(1.05, 1.05), // slightly bigger
                          curve: Curves.easeInOut,
                        ),

                  // AnimatedOpacity(
                  //       opacity: _visible ? 1 : 0,
                  //       duration: const Duration(milliseconds: 1400),
                  //       child: SizedBox(
                  //         width: double.infinity,
                  //         height: 56,
                  //         child: ElevatedButton(
                  //           onPressed: () {
                  //             context.push(AppRouter.premium);
                  //           },
                  //           style: ElevatedButton.styleFrom(
                  //             backgroundColor: AppColors.secondoryColor,
                  //             elevation: 0,
                  //             shape: RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(42),
                  //             ),
                  //           ),
                  //           child: Row(
                  //             mainAxisAlignment: MainAxisAlignment.center,
                  //             children: [
                  //               const Icon(
                  //                 Icons.workspace_premium,
                  //                 color: Colors.amber,
                  //                 size: 22,
                  //               ),
                  //               SizedBox(width: 8),
                  //               Text(
                  //                 localizations.upgrade,
                  //                 style: TextStyle(
                  //                   color: Colors.black45,
                  //                   fontWeight: FontWeight.w600,
                  //                   fontSize: 16,
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //     )
                  const SizedBox(height: 16),
                  // ✅ Watch Ad to Save Button
                  AnimatedOpacity(
                    opacity: _visible ? 1 : 0,
                    duration: const Duration(milliseconds: 1200),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          // check if is subscribe user
                          if (premium.isSubscribe) {
                            try {
                              await GallerySaver.saveVideo(
                                widget.compressedPath,
                                albumName: "Compressed Videos",
                              );

                              // 🧠 Generate a real thumbnail
                              final thumbData =
                                  await VideoThumbnail.thumbnailData(
                                    video: widget.compressedPath,
                                    imageFormat: ImageFormat.PNG,
                                    maxWidth: 400,
                                    quality: 90,
                                  );

                              if (thumbData == null || !mounted) return;

                              // 🪄 Show dialog with thumbnail
                              showDownloadSuccessDialogNew(
                                context: context,
                                title: AppLocalizations.of(
                                  context,
                                )!.downloadSuccess,
                                subtitle: AppLocalizations.of(
                                  context,
                                )!.imageDownloaded,
                                onNextVideo: () {
                                  Navigator.pop(context);
                                  context.go(
                                    AppRouter.dashboard,
                                  ); // go to compression screen again
                                },
                                onDone: () {
                                  Navigator.pop(context);
                                  context.go(
                                    AppRouter.dashboard,
                                  ); // go back to dashboard
                                },
                                // Provide a custom Image widget.
                                image: Image.memory(
                                  thumbData,
                                  height: 140,
                                  width: 140,
                                  fit: BoxFit.cover,
                                ),
                                thumbnailBytes: Uint8List(0),
                              );
                              // showDialog(
                              //   context: context,
                              //   barrierDismissible: false,
                              //   builder: (_) => DownloadSuccessDialog(
                              //     thumbnailBytes: thumbData,
                              //     onNextVideo: () {
                              //       Navigator.pop(context);
                              //       context.go(
                              //         AppRouter.dashboard,
                              //       ); // go to compression screen again
                              //     },
                              //     onDone: () {
                              //       Navigator.pop(context);
                              //       context.go(
                              //         AppRouter.dashboard,
                              //       ); // go back to dashboard
                              //     },
                              //   ),
                              // );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Error saving video: $e"),
                                ),
                              );
                            }
                          } else {
                            context.push(AppRouter.premium);
                          }
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,

                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(42),
                          ),
                          elevation: 0,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(color: Colors.grey[700]!),
                            borderRadius: BorderRadius.circular(42),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset('assets/svg/donwload.svg'),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context)!.download,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
