import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_cleaner_2/core/routes.dart';
import 'package:phone_cleaner_2/core/widgets/gradient_button.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import '../../core/utils/colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/album_duplicate.dart';
import '../../models/duplicate_model.dart';
import '../paywall_screen/paywall_provider.dart';
import 'components/thumbnails_tile.dart';
import 'provider/duplicate_finder_provider.dart';
import 'provider/duplicate_selection_provider.dart';

class DuplicateDetailsScreen extends StatelessWidget {
  final AlbumWithDuplicates album;

  const DuplicateDetailsScreen({super.key, required this.album});

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
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.bgColor,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: album.duplicateGroups.length,
        itemBuilder: (context, index) {
          final group = album.duplicateGroups[index];
          return _buildDuplicateGroup(context, group, index);
        },
      ),
      floatingActionButton: selectionProvider.selectedForDeletion.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GradientButton(
                borderRadius: 30,
                text:
                    "${AppLocalizations.of(context)!.delete} ${selectionProvider.selectedForDeletion.length} ${AppLocalizations.of(context)!.images}",
                onPressed: () {
                  provider.isSubscribe
                      ? _deleteSelected(context)
                      : context.push(AppRouter.premium);
                },
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // bottomNavigationBar:
      // Container(
      //     padding: const EdgeInsets.all(16),
      //     color: Colors.transparent,
      //     child:
      //      SafeArea(
      //       child: ElevatedButton(
      //         onPressed: () {
      // provider.isSubscribe
      //     ? _deleteSelected(context)
      //     : context.push(AppRouter.premium);
      //         },
      //         style: ElevatedButton.styleFrom(
      //           backgroundColor: AppColors.blue,
      //           foregroundColor: Colors.white,
      //           padding: const EdgeInsets.symmetric(vertical: 16),
      //           shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(12),
      //           ),
      //         ),
      //         child: Text(
      //           'Delete ${selectionProvider.selectedForDeletion.length} Images',
      //           style: const TextStyle(
      //             fontSize: 16,
      //             fontWeight: FontWeight.w600,
      //           ),
      //         ),
      //       ),
      //     ),
      //   )
      // : null,
    );
  }

  Widget _buildDuplicateGroup(
    BuildContext context,
    DuplicateGroup group,
    int groupIndex,
  ) {
    final provider = context.watch<DuplicateSelectionProvider>();
    bool allSelected = group.images.every(
      (asset) => provider.isSelected(asset.id),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 5, right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '     Set ${groupIndex + 1} (${group.images.length} copies)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                IconButton(
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
                  icon: SvgPicture.asset(
                    allSelected
                        ? "assets/svg/check_circle.svg"
                        : "assets/svg/circle.svg",
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).primaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Grid
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
            itemBuilder: (context, index) {
              return DuplicateThumbnailTile(asset: group.images[index]);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSelected(BuildContext context) async {
    final provider = context.read<DuplicateSelectionProvider>();
    final ids = provider.selectedForDeletion;

    if (ids.isEmpty) return;

    try {
      // iOS will show its own native confirmation dialog automatically
      final deletedIds = await PhotoManager.editor.deleteWithIds(ids.toList());

      if (deletedIds.isNotEmpty) {
        // ✅ Some or all images were deleted successfully
        context.read<DuplicateFinderProvider>().removeDeletedAssets(deletedIds);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 800),
            content: Text('${deletedIds.length} images deleted'),
            backgroundColor: Colors.transparent,
            behavior: SnackBarBehavior.fixed,
          ),
        );

        provider.clearAll();
        Navigator.pop(context);
      } else {
        // ❌ User cancelled or nothing was deleted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 400),
            content: Text(AppLocalizations.of(context)!.noImagesDeleted),
            backgroundColor: Colors.transparent,
            behavior: SnackBarBehavior.fixed,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 400),
          content: Text('Error deleting images: $e'),
          backgroundColor: Colors.transparent,
          behavior: SnackBarBehavior.fixed,
        ),
      );
    }
  }
}
