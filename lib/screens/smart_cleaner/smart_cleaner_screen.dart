import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart' show Contact;
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:phone_cleaner_2/core/utils/colors.dart';
import 'package:phone_cleaner_2/core/utils/responsive_sizer.dart';
import 'package:phone_cleaner_2/core/widgets/gradient_button.dart';
import 'package:phone_cleaner_2/screens/duplicate_contacts_screen/provider.dart'
    hide Contact;
import 'package:phone_cleaner_2/screens/home_screen/phone_cleaner_home.dart';
import 'package:phone_cleaner_2/screens/smart_cleaner/provider.dart';
import 'package:phone_cleaner_2/screens/smart_cleaner/widget/loading_ring.dart';
import 'package:phone_cleaner_2/screens/smart_cleaner/widget/ring_widget.dart';
import 'package:phone_cleaner_2/screens/smart_cleaner/widget/segment.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../core/widgets/app_bar.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/media_item.dart';
import '../duplicate_image_screen/provider/duplicate_finder_provider.dart';
import '../duplicate_videos_screen/provider.dart';
import '../paywall_screen/paywall_provider.dart';

class SmartCleanerScreen extends StatefulWidget {
  const SmartCleanerScreen({super.key});

  @override
  State<SmartCleanerScreen> createState() => _SmartCleanerScreenState();
}

class _SmartCleanerScreenState extends State<SmartCleanerScreen> {
  bool showPhotos = false;
  bool showVideos = false;
  bool showContacts = false;
  bool _isLoading = true;

  final Map<String, Uint8List?> _thumbnails = {};
  List<SegmentData>? dataSegmentss;
  double formatSize(int bytes) {
    if (bytes < 1024 * 1024) {
      return bytes / 1024; // KB
    } else {
      return bytes / (1024 * 1024); // MB
    }
  }

  double formattedSizeToGB(String formattedSize) {
    final parts = formattedSize.split(" ");
    final value = double.parse(parts.first);
    final unit = parts.last.toUpperCase();

    switch (unit) {
      case "KB":
        return value / (1024 * 1024); // KB → GB
      case "MB":
        return value / 1024; // MB → GB
      case "GB":
        return value;
      default:
        return 0.001;
    }
  }
  double mbToGB(double mb) {
    return mb / 1024;
  }

  // ✅ Convert formatted string → GB
  // double formattedSizeToGB(String formattedSize) {
  //   final parts = formattedSize.split(" ");
  //   if (parts.length < 2) return 0.0;
  //
  //   final value = double.tryParse(parts[0]) ?? 0.0;
  //   final unit = parts[1].toUpperCase();
  //
  //   switch (unit) {
  //     case "KB":
  //       return value / (1024 * 1024);
  //     case "MB":
  //       return value / 1024;
  //     case "GB":
  //       return value;
  //     default:
  //       return 0.0;
  //   }
  // }
  //
  // // ✅ MB → GB
  // double mbToGB(double mb) => mb / 1024;

  @override
  void initState() {
    super.initState();

    // ✅ Fake loading animation delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  // ===========================================================
  // ✅ Build Segments Correctly
  // ===========================================================

  List<SegmentData> buildSegments(BuildContext context) {
    final imageProvider = context.watch<DuplicateFinderProvider>();
    final videoProvider = context.watch<DuplicateVideoFinderProvider>();
    final contactProvider = context.watch<DuplicateContactsProvider>();

    // ✅ Always calculate values in GB
    final photoGB = mbToGB(imageProvider.totalEstimatedDuplicateSizeMB);
    final videoGB = mbToGB(videoProvider.totalEstimatedDuplicateSizeMB);
    final contactGB = formattedSizeToGB(contactProvider.formattedSize);

    return [
      SegmentData(value: photoGB, color: Colors.green),
      SegmentData(value: videoGB, color: Colors.blue),
      SegmentData(value: contactGB, color: Colors.orange),
    ];
  }

  // @override
  // void initState() {
  //   super.initState();
  //   Future.delayed(const Duration(seconds: 3), () {
  //     if (mounted) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     }
  //   });
  //
  //   WidgetsBinding.instance.addPostFrameCallback((val) async {
  //     final provider = Provider.of<StorageProvider>(context, listen: false);
  //     final providers = Provider.of<DuplicateContactsProvider>(
  //       context,
  //       listen: false,
  //     );
  //
  //     await provider.loadContacts();
  //     await provider.computeVideoSizes(batchSize: 10);
  //     await provider.computePhotoSizes(batchSize: 15);
  //     // const int bytesPerContact = 1024; // 1 KB per contact
  //     // int contactBytes = provider.contacts.length * bytesPerContact;
  //
  //     dataSegmentss = [
  //       SegmentData(
  //         value:  mbToGB(
  //           context.read<DuplicateFinderProvider>()
  //               .totalEstimatedDuplicateSizeMB,
  //         ),
  //         color:  Colors.green
  //       ),
  //       SegmentData(
  //         value:  mbToGB(
  //           context.read<DuplicateVideoFinderProvider>()
  //               .totalEstimatedDuplicateSizeMB,
  //         ),
  //         color:Colors.blue.withOpacity(0.23)
  //       ),
  //       SegmentData(
  //         value:  formattedSizeToGB(
  //           context.read<DuplicateContactsProvider>().formattedSize,
  //         ),
  //         color: Colors.orange
  //       ),
  //     ];
  //   });
  // }

  Set<int> selected = {};
  double bytesToGB(int bytes) {
    return bytes / (1024 * 1024 * 1024);
  }
  double formattedSizesToGB(String formatted) {
    final parts = formatted.split(" ");

    if (parts.length < 2) return 0.0;

    final value = double.tryParse(parts[0]) ?? 0.0;
    final unit = parts[1].toUpperCase();

    switch (unit) {
      case "KB":
        return value / (1024 * 1024);
      case "MB":
        return value / 1024;
      case "GB":
        return value;
      case "TB":
        return value * 1024;
      default:
        return value;
    }
  }
  // double get totalValue =>
  //     dataSegments.fold(0, (sum, item) => sum + item.value);
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    print('selected $selected');
    final List<SegmentData> dataSegments = [
      SegmentData(
        value: 99,
        color: Theme.of(context).primaryColor,
        //const Color(0xFFF0B345),
      ), // Gold/Yellow color for the progress
      SegmentData(
        value: 1,
        color: Colors.transparent,
      ), // Transparent for the remaining part of the circle
    ];

    double totalValue = dataSegments.fold(0, (sum, item) => sum + item.value);
    // ✅ Show loading animation first
    if (_isLoading) {
      return Scaffold(
        body: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Theme.of(context).primaryColor,
                  BlendMode.srcIn,
                ),
                child: Lottie.asset(
                  'assets/json/cleaning_animation.json',
                  repeat: true,

                  // fit: BoxFit.cover,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: RingProgressAnimationDemo(
                segments: dataSegments,
                totalValue: totalValue,
              ),
            ),
          ],
        ),
        //  Center(
        //   child: Lottie.asset('assets/json/storage_loader.json', repeat: true),
        // ),
      );
    }

    // ✅ Build segments dynamically
    final segments = buildSegments(context);

    // ✅ Correct total value = sum of all segments
    final totalSegmentsValue =
    segments.fold(0.0, (sum, seg) => sum + seg.value);
    return Scaffold(
      appBar: CustomAppBar(
        title: localizations.phoneCleaner,
        showBackButton: true,
        showActionButton: false,
        onActionTap: () {
          context.push(AppRouter.premium);
        },
      ),

      body: Consumer<StorageProvider>(
        builder: (context, storage, _) {
          if (storage.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
print('storage.total ${storage.total}');
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 0),
              Center(
                child: RingProgressWidget(
                  segments: segments,
                  totalValue: totalSegmentsValue,
                  centerText: "${totalSegmentsValue.toStringAsFixed(2)} GB",
                  innerCircleRadius: 90,
                  ringStrokeWidth: 18,
                ),
              ),


              // 🔵 Storage Circular Indicator
              // Wrap the indicator in a Container to add padding and shadow
              // Container(
              //   margin: const EdgeInsets.only(bottom: 10),
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.grey.withOpacity(0.3),
              //         spreadRadius: 2,
              //         blurRadius: 5,
              //         offset: const Offset(0, 3),
              //       ),
              //     ],
              //     shape: BoxShape.circle,
              //     image: DecorationImage(
              //       image: AssetImage('assets/png/test_bg.png'),
              //       fit: BoxFit.cover,
              //     ),
              //   ),
              //   child: CircularPercentIndicator(
              //     radius: 90.0,
              //     lineWidth: 15.0,
              //     percent: usedPercent.clamp(0.0, 1.0),
              //     animation: true,
              //     animateFromLastPercent: true,
              //     animationDuration: 800,
              //     center: Column(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Text(
              //           "${storage.used.toStringAsFixed(1)} GB",
              //           style: const TextStyle(
              //             fontSize: 20,
              //             fontWeight: FontWeight.bold,
              //             color: Color(0xFF333333),
              //           ),
              //         ),
              //         const SizedBox(height: 4),
              //         // 💡 Provide clear context for the secondary text
              //         Text(
              //           "Used of ${storage.total.toStringAsFixed(1)} GB",
              //           style: const TextStyle(
              //             color: Colors.grey,
              //             fontSize: 10,
              //           ),
              //         ),
              //       ],
              //     ),
              //     rotateLinearGradient: true,
              //     linearGradient: const LinearGradient(
              //       colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
              //       begin: Alignment.topLeft,
              //       end: Alignment.bottomRight,
              //     ),
              //     backgroundColor: Colors.grey.shade300,
              //     circularStrokeCap: CircularStrokeCap.round,
              //   ),
              // ),
              SizedBox(height: 10),
              Text(
                "${storage.used.toStringAsFixed(1)} GB/ ${storage.total.toStringAsFixed(1)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                AppLocalizations.of(context)!.occupiesSpace,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 30),

              Container(
                height: 400.h,
                width: double.infinity,
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  color: AppColors.bgSecondry,
                ),
                child: Column(
                  children: [
                    // Text(
                    //   'storage.photos ${storage.photos.fold<int>(0, (s, i) => s + i.sizeInBytes) / 1e9}',
                    // ),
                    SizedBox(height: 40.h),
                    // 🖼️ Photos Section
                    _buildAnimatedSection(
                      index: 2,
                      title: localizations.images,
                      size:
                          "${ context.watch<DuplicateFinderProvider>()
                              .totalEstimatedDuplicateSizeFormatted} ",
                      isExpanded: false,
                      onToggle: () async {
                        setState(() {
                          if (selected.contains(2)) {
                            selected.remove(2);
                          } else {
                            selected.add(2);
                          }
                        });
                        setState(() {
                          showPhotos = !showPhotos;
                          showVideos = false;
                          showContacts = false;
                        });

                        if (showPhotos) {
                          final p = context.read<StorageProvider>();
                          if (p.photos.isNotEmpty &&
                              p.photos.first.sizeInBytes == 0 &&
                              !p.isCalculatingSizes) {
                            await p.computePhotoSizes(batchSize: 15);
                          }
                        }
                      },
                      children: _buildMediaPreview(storage.photos),
                      assetName: 'assets/svg/image.svg',
                      color: Colors.green
                    ),

                    const SizedBox(height: 18),

                    // 🎥 Videos Section
                    _buildAnimatedSection(
                      index: 1,
                      color:  Colors.blue,
                      // Color(0xffFE7F7F),
                      title: localizations.videos,
                      size:
                          "${ context.watch<DuplicateVideoFinderProvider>()
                              .totalEstimatedDuplicateSizeFormatted} ",
                      isExpanded: showVideos,
                      onToggle: () async {
                        setState(() {
                          if (selected.contains(1)) {
                            selected.remove(1);
                          } else {
                            selected.add(1);
                          }
                        });
                        setState(() {
                          showVideos = !showVideos;
                          showPhotos = false;
                          showContacts = false;
                        });

                        if (showVideos) {
                          final p = context.read<StorageProvider>();
                          if (p.videos.isNotEmpty &&
                              p.videos.first.sizeInBytes == 0 &&
                              !p.isCalculatingSizes) {
                            await p.computeVideoSizes(batchSize: 10);
                          }
                        }
                      },
                      children: _buildMediaPreview(storage.videos),
                      assetName: 'assets/svg/videos.svg',
                    ),

                    const SizedBox(height: 18),
                    // 👤 Contacts Section
                    Consumer<DuplicateContactsProvider>(
                      builder: (context, prov, child) {
                        // const int bytesPerContact = 1024; // 1 KB per contact
                        // int contactBytes =
                        //     prov.contacts.length * bytesPerContact;
                        return _buildAnimatedSection(
                          index: 0,
                          color: Colors.orange,
                          // Color(0xffFED89B),
                          title: localizations.contacts,

                          size:  formattedSizesToGB(
                            context.watch<DuplicateContactsProvider>().formattedSize,
                          ).toString(),
                          isExpanded: showContacts,
                          onToggle: () async {
                            setState(() {
                              if (selected.contains(0)) {
                                selected.remove(0);
                              } else {
                                selected.add(0);
                              }
                            });
                            setState(() {
                              showContacts = !showContacts;
                              showPhotos = false;
                              showVideos = false;
                            });

                            if (showContacts && storage.contacts.isEmpty) {
                              await storage.loadContacts();
                            }
                          },
                          children: _buildContactPreview(storage.contacts),
                          assetName: 'assets/svg/contacts.svg',
                        );
                      },
                    ),

                    // const Spacer(),
                    SizedBox(height: 30.h),
                    // 🚀 Smart Clean Button
                    CustomButtonWidget(
                      text: localizations.startSmartClean,
                      onPressed: () async {
                        if (selected.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Theme.of(context).primaryColor,
                              content: const Text(
                                "Please select at least one item",
                                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
                              ),
                            ),
                          );
                          return;
                        }

                        final isPremium = context.read<PremiumProvider>().isSubscribe;
                        final storage = context.read<StorageProvider>();

                        if (!isPremium) {
                          // Pass the 'selected' set to the provider method
                          await storage.smartCleanAll(context, selected).then((va) {
                            // Success logic here
                          
                          });
                        } else {
                          context.push(AppRouter.premium);
                        }
                      },
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFC94A), Color(0xFFFF9F1C)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: 35.0,
                      paddingVertical: 15.0,
                      elevation: 5,
                      isLoading: storage.isCleaning,
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),

              // SizedBox(
              //   width: double.infinity,
              //   height: 55,
              //   child: ElevatedButton(
              //     onPressed: () async {
              //       final isPremium = context
              //           .read<PremiumProvider>()
              //           .isSubscribe;
              //       if (isPremium) {
              //         final storage = context.read<StorageProvider>();
              //         await storage.smartCleanAll();

              //         if (context.mounted) {
              //           ScaffoldMessenger.of(context).showSnackBar(
              //             const SnackBar(
              //               content: Text("Smart Clean complete!"),
              //               backgroundColor: Colors.green,
              //             ),
              //           );
              //         }
              //       } else {
              //         context.push(AppRouter.premium);
              //       }
              //     },
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: const Color(0xFF2F62FF),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(16),
              //       ),
              //     ),
              //     child: Consumer<StorageProvider>(
              //       builder: (context, storage, _) {
              //         return storage.isCleaning
              //             ? const CircularProgressIndicator(
              //                 color: Colors.white,
              //               )
              //             : Text(
              //                 localizations.startSmartClean,
              //                 style: TextStyle(
              //                   color: Colors.white,
              //                   fontWeight: FontWeight.bold,
              //                   fontSize: 16,
              //                 ),
              //               );
              //       },
              //     ),
              //   ),
              // ),
            ],
          );
        },
      ),
    );
  }

  /// 📦 Expandable Animated Section
  Widget _buildAnimatedSection({
    required String title,
    required String size,
    required String assetName,
    required bool isExpanded,
    required Color color,
    required VoidCallback onToggle,
    required List<Widget> children,
    required int index,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.bgColor,
        border: Border.all(color: Colors.grey[600]!),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          ListTile(
            tileColor: AppColors.bgSecondry,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 16.h,
                  width: 16.w,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  height: 30.h,
                  width: 30.w,
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: SvgPicture.asset(assetName),
                ),
              ],
            ),

            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            // subtitle
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  size,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                SizedBox(width: 8),
                ?selected.contains(index)
                    ? SvgPicture.asset(
                        'assets/svg/check_circle.svg',
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).primaryColor,
                          BlendMode.srcIn,
                        ),
                      )
                    : null,
              ],
            ),
            onTap: onToggle,
          ),
          // AnimatedCrossFade(
          //   duration: const Duration(milliseconds: 300),
          //   crossFadeState: isExpanded
          //       ? CrossFadeState.showFirst
          //       : CrossFadeState.showSecond,
          //   firstChild: SizedBox(
          //     height: 110,
          //     child: ListView(
          //       scrollDirection: Axis.horizontal,
          //       padding: const EdgeInsets.only(left: 16, bottom: 10),
          //       children: children,
          //     ),
          //   ),
          //   secondChild: const SizedBox.shrink(),
          // ),
        ],
      ),
    );
  }

  /// 🖼️ Media Preview (uses cached thumbnails)
  List<Widget> _buildMediaPreview(List<MediaItem> items) {
    if (items.isEmpty) {
      return [const Center(child: Text("No Media Found"))];
    }

    return items.map((item) {
      return FutureBuilder<Uint8List?>(
        future: _getThumbnail(item),
        builder: (context, snapshot) {
          final data = snapshot.data;
          return Container(
            margin: const EdgeInsets.only(right: 10, top: 8),
            width: 90,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              image: data != null
                  ? DecorationImage(image: MemoryImage(data), fit: BoxFit.cover)
                  : null,
            ),
            child: data == null
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : null,
          );
        },
      );
    }).toList();
  }

  /// ⚡ Optimized thumbnail fetcher with cache
  Future<Uint8List?> _getThumbnail(MediaItem item) async {
    if (_thumbnails.containsKey(item.id)) return _thumbnails[item.id];

    try {
      final thumb = await item.asset.thumbnailDataWithSize(
        const ThumbnailSize(64, 64),
        quality: 80,
      );
      _thumbnails[item.id] = thumb;
      return thumb;
    } catch (e) {
      debugPrint("Thumbnail error: $e");
      return null;
    }
  }

  /// 👤 Placeholder for contacts
  /// 👤 Show contacts preview
  List<Widget> _buildContactPreview(List<Contact> contacts) {
    if (contacts.isEmpty) {
      return [const Center(child: Text("No Contacts Found"))];
    }

    return contacts.take(10).map((contact) {
      final name = contact.displayName.isNotEmpty
          ? contact.displayName
          : "No Name";
      final avatar = contact.photo;
      return Container(
        width: 90,
        margin: const EdgeInsets.only(right: 10, top: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: avatar != null ? MemoryImage(avatar) : null,
              child: avatar == null
                  ? const Icon(Icons.person, size: 30, color: Colors.grey)
                  : null,
            ),
            const SizedBox(height: 5),
            Text(
              name,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
    }).toList();
  }
}
