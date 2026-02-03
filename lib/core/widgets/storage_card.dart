import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_cleaner_2/core/routes.dart';
import 'package:phone_cleaner_2/core/utils/responsive_sizer.dart';
import 'package:phone_cleaner_2/screens/duplicate_contacts_screen/provider.dart';
import 'package:phone_cleaner_2/screens/duplicate_image_screen/provider/duplicate_finder_provider.dart';
import 'package:phone_cleaner_2/screens/duplicate_videos_screen/provider.dart';
import 'package:phone_cleaner_2/screens/home_screen/widget/square_precentage.dart';
import 'package:provider/provider.dart';

import '../../screens/smart_cleaner/provider.dart';

class StorageUsageCard extends StatefulWidget {
  const StorageUsageCard({super.key});

  @override
  State<StorageUsageCard> createState() => _StorageUsageCardState();
}

class _StorageUsageCardState extends State<StorageUsageCard> {
  @override
  // Widget build(BuildContext context) {
  // final storage = context.watch<StorageProvider>();
  // final localizations = AppLocalizations.of(context)!;
  // final theme = context.watch<ThemeProvider>().theme;
  // final usedPercent = (storage.used / storage.total).clamp(0.0, 1.0);
  //   return Container(
  //     width: double.infinity,
  //     height: 200.h,
  //     // padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       // color: Theme.of(context).primaryColor,
  //       borderRadius: BorderRadius.circular(24),
  //       image: DecorationImage(
  //         fit: BoxFit.fill,
  //         image: AssetImage(theme.assets.background),
  //         // image: AssetImage('assets/png/main_img.png'),
  //       ),
  //     ),
  //     child: Stack(
  //       // crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // Text('${Theme.of(context).primaryColor}'),
  //         Align(
  //           alignment: Alignment.centerLeft,
  //           child: Padding(
  //             padding: EdgeInsets.only(left: 20.0.w),
  //             child: SquareProgressIndicator(
  //               targetValue: usedPercent,
  //               size: 140,
  //             ),
  //           ),
  //         ),
  //         Align(
  //           alignment: Alignment.topRight,
  //           child: Padding(
  //             padding: const EdgeInsets.only(top: 40.0, right: 16),
  //             child: Container(
  //               color: Colors.transparent,
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   SizedBox(
  //                     width: 155.w,
  //                     child: Text(
  //                       localizations.storageUsage,
  //                       style: TextStyle(
  //                         fontFamily: 'GilroyBold',
  //                         fontSize: 22.fSize,
  //                         color: Colors.white,
  //                       ),
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                   ),
  //                   SizedBox(
  //                     width: 155.w,
  //                     child: Text(
  //                       "${storage.used.toStringAsFixed(1)}/ ${storage.total.toStringAsFixed(0)}GB ${localizations.used}",
  //                       style: TextStyle(
  //                         color: Colors.white,
  //                         fontFamily: "GilroyBold",
  //                         fontSize: 18.fSize,
  //                         // fontWeight: FontWeight.w900,
  //                       ),
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                   ),
  //                   // Text('data'),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //         Align(
  //           alignment: Alignment.bottomRight,
  //           child: Padding(
  //             padding: const EdgeInsets.only(right: 25.0, bottom: 22),
  //             child: InkWell(
  //               onTap: () {
  //                 ClickDelay.run(() {
  //                   Constants.isInterSplash = true;
  //                   if (storage.isPermissionGranted) {
  //                     context.push(AppRouter.smartCleaner);
  //                     Constants.isInterSplash = false;
  //                   } else {
  //                     storage.requestPermission(context);
  //                   }
  //                 });
  //               },
  //               child: Container(
  //                 width: 130.w,
  //                 height: 30.h,
  //                 decoration: BoxDecoration(
  //                   color: Color(0xff292B2B),
  //                   // Color(0xff292B2B),
  //                   borderRadius: BorderRadius.only(
  //                     topLeft: Radius.circular(25),
  //                   ),
  //                 ),
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.end,
  //                   children: [
  //                     Container(
  //                       width: 90,
  //                       color: Colors.transparent,
  //                       child: Text(
  //                         AppLocalizations.of(context)!.smartclean,
  //                         style: TextStyle(
  //                           fontFamily: "GilroyBold",
  //                           color: Colors.white,
  //                           fontSize: 14.fSize,
  //                         ),
  //                         overflow: TextOverflow.ellipsis,
  //                       ),
  //                     ),
  //                     SizedBox(width: 10),
  //                     CircleAvatar(
  //                       backgroundColor: Colors.white,
  //                       radius: 10.adaptSize,
  //                       child: Center(
  //                         child: Icon(
  //                           Icons.arrow_forward_ios_rounded,
  //                           size: 14.adaptSize,
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((val) async {
      final provider = Provider.of<StorageProvider>(context, listen: false);
      final providers = Provider.of<DuplicateContactsProvider>(
        context,
        listen: false,
      );

      await provider.loadContacts();
      await provider.computeVideoSizes(batchSize: 10);
      await provider.computePhotoSizes(batchSize: 15);
      // const int bytesPerContact = 1024; // 1 KB per contact
      // int contactBytes = provider.contacts.length * bytesPerContact;

      // dataSegmentss = [
      //   SegmentData(
      //     value: provider.photos.isEmpty
      //         ? 0.001
      //         : provider.photos.fold<int>(0, (s, i) => s + i.sizeInBytes) / 1e9,
      //     color: const Color.fromARGB(255, 0, 52, 240),
      //   ),
      //   SegmentData(
      //     value: provider.videos.isEmpty
      //         ? 0.001
      //         : provider.videos.fold<int>(0, (s, i) => s + i.sizeInBytes) / 1e9,
      //     color: const Color.fromARGB(156, 237, 0, 0),
      //   ),
      //   SegmentData(
      //     value: providers.formattedSize.isEmpty
      //         ? 0.001
      //         : formattedSizeToGB(providers.formattedSize),
      //     color: const Color.fromARGB(255, 200, 124, 0),
      //   ),
      // ];
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageProvider>();
    final usedPercent = (storage.used / storage.total).clamp(0.0, 1.0);
    // print('storage.total ${storage.total}');
    // print('storage.used ${storage.used}');
    print(
      'other storage ${double.parse(context.watch<DuplicateContactsProvider>().formattedSize.split(' ').first)}',
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, bottom: 20, left: 10, right: 10),
      decoration: BoxDecoration(
        color: Color(0xff292B2B),
        border: Border.all(color: Colors.grey[700]!),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Storage Usage",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${(usedPercent * 100).toInt()}% Full",
                style: const TextStyle(
                  color: Color(0xFF81DEEA),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Divider(color: Colors.grey[700]),
          const SizedBox(height: 20),
          // Content Row (Chart + Stats)
          Container(
            color: Colors.transparent,
            child: Row(
              children: [
                // Left: Circular Chart
                Expanded(
                  // width: 140.w,
                  // height: 140.h,
                  child: CustomPaint(
                    painter: SegmentedCircularPainter(
                      totalStorage: storage.total,
                      // imageStorage: 49,
                      // videoStorage: 140,
                      // contactStorage: 202,
                      imageStorage: double.parse(
                        context
                            .watch<DuplicateFinderProvider>()
                            .totalEstimatedDuplicateSizeFormatted
                            .split(' ')
                            .first,
                      ),
                      videoStorage: double.parse(
                        context
                            .watch<DuplicateVideoFinderProvider>()
                            .totalEstimatedDuplicateSizeFormatted
                            .split(' ')
                            .first,
                      ),
                      contactStorage: double.parse(
                        context
                            .watch<DuplicateContactsProvider>()
                            .formattedSize
                            .split(' ')
                            .first,
                      ),
                    ),
                    // child: Center(
                    //   child: Text(
                    //     "${(usedPercent * 100).toInt()}%",
                    //     style: const TextStyle(
                    //       color: Colors.white,
                    //       fontSize: 24,
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //   ),
                    // ),
                  ),
                ),
                const SizedBox(width: 30),
                // Right: Text Stats & Button
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${(storage.total - storage.used).toStringAsFixed(0)} GB free",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.fSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${storage.used.toStringAsFixed(1)}/${storage.total.toStringAsFixed(0)}GB used",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.fSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Smart Clean Button
                      ElevatedButton(
                        onPressed: () => context.push(AppRouter.smartCleaner),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFFD4AF37,
                          ), // Gold Color
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              "Smart Clean",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_circle_right_outlined, size: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
