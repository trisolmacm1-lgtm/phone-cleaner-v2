import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:phone_cleaner_2/core/utils/responsive_sizer.dart';
import 'package:photo_manager/photo_manager.dart';

class MediaCategoryCard extends StatelessWidget {
  final String assetName;
  final Color iconBg;
  final String title;
  final List<AssetEntity> previewImages;
  final String itemCount;
  final String totalSize, path;
  final VoidCallback onTap;

  const MediaCategoryCard({
    super.key,
    required this.assetName,
    required this.iconBg,
    required this.title,
    required this.previewImages,
    required this.itemCount,
    required this.totalSize,
    required this.path,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 165.w,
        padding: EdgeInsets.only(left: 10.w, right: 10),
        decoration: BoxDecoration(
          color: Color(0xff292B2B),
          border: Border.all(color: Colors.grey[700]!),
          borderRadius: BorderRadius.circular(26),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- Top Row icon + Title ---
            Row(
              children: [
                Container(
                  height: 36.h,
                  width: 36.w,
                  decoration: BoxDecoration(
                    // color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(image: AssetImage(path)),
                  ),
                  padding: EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SvgPicture.asset(assetName),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.fSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // --- Thumbnails + Count ---
            Row(
              children: [
                ...previewImages
                    .take(2)
                    .map(
                      (img) => FutureBuilder<Uint8List?>(
                        future: previewImages[0].thumbnailDataWithSize(
                          const ThumbnailSize(200, 200),
                        ),
                        builder: (context, snapshot) {
                          return Container(
                            margin: const EdgeInsets.only(right: 6),
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[500]!),
                              image: snapshot.hasData
                                  ? DecorationImage(
                                      image: MemoryImage(snapshot.data!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              //  DecorationImage(
                              //   image: AssetImage(img),
                              //   fit: BoxFit.cover,
                              // ),
                            ),
                          );
                        },
                      ),
                    ),
                Container(
                  width: 35.w,
                  height: 35.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(0xff222323),
                    boxShadow: [
                      BoxShadow(color: Colors.grey[600]!, offset: Offset(0, 2)),
                    ],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    itemCount,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // --- Bottom Row storage + arrow ---
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
              // margin: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Color(0xff222323),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    totalSize,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).primaryColor,
                    size: 24.adaptSize,
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
