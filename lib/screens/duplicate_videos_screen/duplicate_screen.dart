import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:phone_cleaner_2/screens/duplicate_videos_screen/provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/app_bar.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/album_duplicate.dart';
import 'duplicate_details_view.dart';

class DuplicateVideoFinderScreen extends StatefulWidget {
  const DuplicateVideoFinderScreen({super.key});

  @override
  State<DuplicateVideoFinderScreen> createState() =>
      _DuplicateVideoFinderScreenState();
}

class _DuplicateVideoFinderScreenState
    extends State<DuplicateVideoFinderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((va) {
      context.read<DuplicateVideoFinderProvider>().startScan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DuplicateVideoFinderProvider>();
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CustomAppBar(
        title: localizations.videos,
        showBackButton: true,
        showActionButton: false,
      ),

      body: _buildBody(provider, localizations),
    );
  }

  Widget _buildBody(
    DuplicateVideoFinderProvider provider,
    AppLocalizations localizations,
  ) {
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
              localizations.noDuplicateVideos,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              localizations.videoLibraryClean,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (provider.isScanning || provider.isLoading)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  localizations.scanningDuplicateVideos,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: provider.scanProgress,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                const SizedBox(height: 6),
                Text(
                  '${(provider.scanProgress * 100).toInt()}%',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.albums.length,
            itemBuilder: (context, index) {
              final album = provider.albums[index];
              return _buildAlbumCard(album, localizations);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAlbumCard(
    AlbumWithDuplicates album,
    AppLocalizations localizations,
  ) {
    List<AssetEntity> previewVideos = [];
    for (var group in album.duplicateGroups.take(2)) {
      previewVideos.addAll(group.images.take(2));
      if (previewVideos.length >= 4) break;
    }

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DuplicateVideoDetailsScreen(album: album),
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
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      album.estimatedSize,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: previewVideos.length,
                itemBuilder: (context, index) {
                  return FutureBuilder<Uint8List?>(
                    future: previewVideos[index].thumbnailDataWithSize(
                      const ThumbnailSize(64, 64),
                    ),
                    builder: (context, snapshot) {
                      return Container(
                        width: 90,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[300],
                          image: snapshot.hasData
                              ? DecorationImage(
                                  image: MemoryImage(snapshot.data!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: !snapshot.hasData
                            ? const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.play_circle_fill,
                                color: Colors.white70,
                                size: 32,
                              ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
