import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:phone_cleaner_2/core/utils/colors.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/app_bar.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/album_duplicate.dart';
import 'duplicate_details.dart';
import 'provider/duplicate_finder_provider.dart';

class DuplicateFinderScreen extends StatefulWidget {
  const DuplicateFinderScreen({super.key});

  @override
  State<DuplicateFinderScreen> createState() => _DuplicateFinderScreenState();
}

class _DuplicateFinderScreenState extends State<DuplicateFinderScreen> {
  @override
  void initState() {
    super.initState();
    // log('duplicate img screen');
    WidgetsBinding.instance.addPostFrameCallback((va) {
      context.read<DuplicateFinderProvider>().startScan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DuplicateFinderProvider>();
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CustomAppBar(
        title: localizations.images,
        showBackButton: true,
        showActionButton: true,
        actionIcon: "assets/svg/ic_premium.svg",
        onActionTap: () {},
      ),
      body: _buildBody(provider, localizations),
    );
  }

  Widget _buildBody(
    DuplicateFinderProvider provider,
    AppLocalizations localizations,
  ) {
    // If nothing found and not scanning → show empty state
    if (provider.albums.isEmpty &&
        !provider.isScanning &&
        !provider.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              localizations.noDuplicateImages,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              localizations.imageLibraryClean,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // ✅ Sticky progress bar with album list
    return Column(
      children: [
        // Sticky header (progress bar)
        if (provider.isScanning || provider.isLoading)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.bgSecondry,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  localizations.scanningDuplicates,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: provider.scanProgress,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                const SizedBox(height: 6),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    '${(provider.scanProgress * 100).toInt()}%',
                    key: ValueKey(provider.scanProgress),
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),

        // List of found albums
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.albums.length,
            itemBuilder: (context, index) {
              final album = provider.albums[index];
              return _buildAlbumCard(album);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAlbumCard(AlbumWithDuplicates album) {
    List<AssetEntity> previewImages = [];
    for (var group in album.duplicateGroups.take(2)) {
      previewImages.addAll(group.images.take(2));
      if (previewImages.length >= 4) break;
    }

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DuplicateDetailsScreen(album: album),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Album header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          album.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${album.duplicateCount} duplicates',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Container(
                  //   padding: const EdgeInsets.symmetric(
                  //     horizontal: 12,
                  //     vertical: 6,
                  //   ),
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   child:
                  // ),
                  Text(
                    album.estimatedSize,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Preview thumbnails
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                height:
                    150, // Increase height to accommodate the grid structure
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Large Image (First preview image)
                    if (previewImages.isNotEmpty)
                      Expanded(
                        flex: 1,
                        child: _buildPreviewImage(
                          asset: previewImages[0],
                          margin: const EdgeInsets.only(right: 8),
                          borderRadius: 12,
                        ),
                      ),

                    // 2. Grid for Smaller Images (Next three preview images)
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          // Top two small images
                          Expanded(
                            child: Row(
                              children: [
                                if (previewImages.length > 1)
                                  Expanded(
                                    child: _buildPreviewImage(
                                      asset: previewImages[1],
                                      margin: const EdgeInsets.only(
                                        right: 4,
                                        bottom: 4,
                                      ),
                                      borderRadius: 8,
                                    ),
                                  ),
                                if (previewImages.length > 2)
                                  Expanded(
                                    child: _buildPreviewImage(
                                      asset: previewImages[2],
                                      margin: const EdgeInsets.only(
                                        left: 4,
                                        bottom: 4,
                                      ),
                                      borderRadius: 8,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // Bottom one small image (or two if you modify the loop)
                          Expanded(
                            child: Row(
                              children: [
                                if (previewImages.length > 3)
                                  Expanded(
                                    child: _buildPreviewImage(
                                      asset: previewImages[3],
                                      margin: const EdgeInsets.only(
                                        right: 4,
                                        top: 4,
                                      ),
                                      borderRadius: 8,
                                    ),
                                  ),
                                // Placeholder for a fourth image or an empty space
                                if (previewImages.length <= 3 &&
                                    previewImages.length > 1)
                                  const Expanded(child: SizedBox.shrink()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Preview thumbnails
            // SizedBox(
            //   height: 100,
            //   child: ListView.builder(
            //     scrollDirection: Axis.horizontal,
            //     padding: const EdgeInsets.symmetric(horizontal: 12),
            //     itemCount: previewImages.length,
            //     itemBuilder: (context, imgIndex) {
            //       return FutureBuilder<Uint8List?>(
            //         future: previewImages[imgIndex].thumbnailDataWithSize(
            //           const ThumbnailSize(200, 200),
            //         ),
            //         builder: (context, snapshot) {
            //           return Container(
            //             width: 90,
            //             margin: const EdgeInsets.only(right: 8, bottom: 12),
            //             decoration: BoxDecoration(
            //               borderRadius: BorderRadius.circular(12),
            //               color: Colors.grey[300],
            //               image: snapshot.hasData
            //                   ? DecorationImage(
            //                       image: MemoryImage(snapshot.data!),
            //                       fit: BoxFit.cover,
            //                     )
            //                   : null,
            //             ),
            //             child: !snapshot.hasData
            //                 ? const Center(
            //                     child: CircularProgressIndicator(
            //                       strokeWidth: 2,
            //                     ),
            //                   )
            //                 : null,
            //           );
            //         },
            //       );
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewImage({
    required AssetEntity asset,
    required EdgeInsetsGeometry margin,
    required double borderRadius,
  }) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(const ThumbnailSize(200, 200)),
      builder: (context, snapshot) {
        return Container(
          margin: margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: Colors.grey[300],
            image: snapshot.hasData
                ? DecorationImage(
                    image: MemoryImage(snapshot.data!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: !snapshot.hasData
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : null,
        );
      },
    );
  }
}
