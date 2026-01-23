import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_cleaner_2/core/routes.dart';
import 'package:phone_cleaner_2/core/utils/colors.dart';
import 'package:phone_cleaner_2/core/widgets/gradient_button.dart';
import 'package:phone_cleaner_2/screens/duplicate_videos_screen/provider.dart';
import 'package:phone_cleaner_2/screens/paywall_screen/paywall_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../models/album_duplicate.dart';
import '../../models/duplicate_model.dart';
import '../duplicate_image_screen/components/thumbnails_tile.dart';
import '../duplicate_image_screen/provider/duplicate_selection_provider.dart';

class DuplicateVideoDetailsScreen extends StatelessWidget {
  final AlbumWithDuplicates album;
  const DuplicateVideoDetailsScreen({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    final selectionProvider = context.watch<DuplicateSelectionProvider>();
    final provider = context.watch<PremiumProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: SvgPicture.asset("assets/svg/ic_back.svg", color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
            selectionProvider.clearAll();
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(album.name),
            Text(
              '${album.duplicateGroups.length} duplicate groups',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: album.duplicateGroups.length,
        itemBuilder: (context, index) {
          final group = album.duplicateGroups[index];
          return _buildGroup(context, group, index);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: selectionProvider.selectedForDeletion.isNotEmpty
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: Colors.transparent,
              child: GradientButton(
                borderRadius: 30,
                text:
                    "${AppLocalizations.of(context)!.delete} ${selectionProvider.selectedForDeletion.length} ${AppLocalizations.of(context)!.videos}",
                onPressed: () => provider.isSubscribe
                    ? _deleteSelected(context)
                    : context.push(AppRouter.premium),
              ),

              //  ElevatedButton(
              // onPressed: () => provider.isSubscribe
              //     ? _deleteSelected(context)
              //     : context.push(AppRouter.premium),
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: AppColors.blue,
              //     padding: const EdgeInsets.symmetric(vertical: 16),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //   ),
              //   child: Text(
              //     'Delete ${selectionProvider.selectedForDeletion.length} Videos',
              //     style: const TextStyle(
              //       fontSize: 16,
              //       fontWeight: FontWeight.w600,
              //       color: Colors.white,
              //     ),
              //   ),
              // ),
            )
          : null,
    );
  }

  Widget _buildGroup(BuildContext context, DuplicateGroup group, int index) {
    final provider = context.watch<DuplicateSelectionProvider>();
    bool allSelected = group.images.every((a) => provider.isSelected(a.id));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 8, bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Duplicate Set ${index + 1} (${group.images.length} copies)',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: SvgPicture.asset(
                    allSelected
                        ? "assets/svg/check_circle.svg"
                        : "assets/svg/circle.svg",
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).primaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: () {
                    if (allSelected) {
                      provider.deselectGroup(
                        group.images.map((e) => e.id).toList(),
                      );
                    } else {
                      provider.selectGroup(
                        group.images.map((e) => e.id).toList(),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: group.images.length,
            itemBuilder: (context, i) =>
                DuplicateThumbnailTile(asset: group.images[i]),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSelected(BuildContext context) async {
    final local = AppLocalizations.of(context)!;
    final provider = context.read<DuplicateSelectionProvider>();
    final ids = provider.selectedForDeletion;

    if (ids.isEmpty) return;

    try {
      final deletedIds = await PhotoManager.editor.deleteWithIds(ids.toList());

      if (deletedIds.isNotEmpty) {
        context.read<DuplicateVideoFinderProvider>().removeDeletedAssets(
          deletedIds,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.bgColor,
            content: Text(
              '${deletedIds.length} ${local.videos} ${local.delete}',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
        provider.clearAll();
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Error deleting videos: $e',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }
}
