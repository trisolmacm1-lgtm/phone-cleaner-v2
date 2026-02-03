import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_cleaner_2/core/routes.dart';
import 'package:phone_cleaner_2/core/utils/helper_method.dart';
import 'package:phone_cleaner_2/core/utils/responsive_sizer.dart';
import 'package:phone_cleaner_2/screens/duplicate_image_screen/provider/duplicate_finder_provider.dart';
import 'package:phone_cleaner_2/screens/duplicate_videos_screen/provider.dart';
import 'package:phone_cleaner_2/screens/home_screen/widget/media_category_card.dart';
import 'package:provider/provider.dart';

import '../../core/utils/colors.dart';
import '../../core/widgets/app_bar.dart';
import '../../core/widgets/storage_card.dart';
import '../../l10n/generated/app_localizations.dart';
import '../duplicate_contacts_screen/provider.dart';
import '../smart_cleaner/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late StorageProvider storage;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((va) {
      storage = context.read<StorageProvider>();
      final provider = Provider.of<DuplicateFinderProvider>(
        context,
        listen: false,
      );
      final provider1 = Provider.of<DuplicateVideoFinderProvider>(
        context,
        listen: false,
      );
      final provider2 = Provider.of<DuplicateContactsProvider>(
        context,
        listen: false,
      );
      print('albums ${provider.albums.length}');
      if (provider.albums.isEmpty ||
          provider1.albums.isEmpty ||
          provider2.duplicateGroups.isEmpty) {
        provider.startScan();
        provider1.startScan();
        if (provider2.permissionStatus) {
          provider2.findDuplicates();
        }
        // provider2.findDuplicates();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final contactProvider = context.watch<DuplicateContactsProvider>();

    return Scaffold(
      appBar: CustomAppBar(
        title: localizations.phoneCleaner,
        showBackButton: false,
        showActionButton: true,
        actionIcon: "assets/svg/ic_premium.svg",
        onActionTap: () {
          context.push(AppRouter.premium);
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const StorageUsageCard(),
                const SizedBox(height: 14),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.adaptSize,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    MediaCategoryCard(
                      assetName: "assets/svg/image.svg",
                      iconBg: Color(0xFFE1B64F),
                      title: localizations.images,
                      previewImages:
                          context
                              .watch<DuplicateFinderProvider>()
                              .albums
                              .isEmpty
                          ? []
                          : [
                              context
                                  .watch<DuplicateFinderProvider>()
                                  .albums[0]
                                  .duplicateGroups[0]
                                  .images[0],
                              context
                                  .watch<DuplicateFinderProvider>()
                                  .albums[0]
                                  .duplicateGroups[0]
                                  .images[0],
                              // context
                              //     .watch<DuplicateFinderProvider>()
                              //     .albums[0]
                              //     .duplicateGroups[0]
                              //     .images[0],
                              // context
                              //     .watch<DuplicateFinderProvider>()
                              //     .albums[1]
                              //     .duplicateGroups[1]
                              //     .images[1],
                            ],
                      itemCount:
                          context
                              .watch<DuplicateFinderProvider>()
                              .albums
                              .isEmpty
                          ? "..."
                          : context
                                .watch<DuplicateFinderProvider>()
                                .albums[0]
                                .totalImages
                                .toString(),

                      totalSize: context
                          .watch<DuplicateFinderProvider>()
                          .totalEstimatedDuplicateSizeFormatted,
                      onTap: () {
                        ClickDelay.run(() {
                          storage.isPermissionGranted
                              ? context.push(AppRouter.duplicateImage)
                              : storage.requestPermission(context);
                        });
                      },
                      path: 'assets/png/img.png',
                    ),
                    MediaCategoryCard(
                      assetName: 'assets/svg/videos.svg',
                      iconBg: Color(0xFFE1B64F),
                      title: localizations.videos,
                      previewImages:
                          context
                              .watch<DuplicateVideoFinderProvider>()
                              .albums
                              .isEmpty
                          ? []
                          : [
                              context
                                  .watch<DuplicateVideoFinderProvider>()
                                  .albums[0]
                                  .duplicateGroups[0]
                                  .images[0],
                              context
                                  .watch<DuplicateVideoFinderProvider>()
                                  .albums[0]
                                  .duplicateGroups[0]
                                  .images[0],
                            ],
                      itemCount:
                          context
                              .watch<DuplicateVideoFinderProvider>()
                              .albums
                              .isEmpty
                          ? "..."
                          : context
                                .watch<DuplicateVideoFinderProvider>()
                                .albums[0]
                                .totalImages
                                .toString(),

                      totalSize: context
                          .watch<DuplicateVideoFinderProvider>()
                          .totalEstimatedDuplicateSizeFormatted,
                      onTap: () {
                        ClickDelay.run(() {
                          storage.isPermissionGranted
                              ? context.push(AppRouter.duplicateVideo)
                              : storage.requestPermission(context);
                        });
                      },
                      path: 'assets/png/video.png',
                    ),

                    // _buildCategoryButton(
                    //   icon: "assets/dashboard/ic_gallery_db.svg",
                    //   label: localizations.images,
                    // size: context
                    //     .watch<DuplicateFinderProvider>()
                    //     .totalEstimatedDuplicateSizeFormatted,
                    //   color: const Color(0xFFE1B64F),
                    //   onTap: () {

                    //   },
                    // ),
                    // _buildCategoryButton(
                    //   icon: "assets/dashboard/ic_video_db.svg",
                    //   label: localizations.videos,
                    // size: context
                    //     .watch<DuplicateVideoFinderProvider>()
                    //     .totalEstimatedDuplicateSizeFormatted,
                    //   color: const Color(0xFFE1B64F),
                    //   onTap: () {

                    //   },
                    // ),

                    // _buildCategoryButton(
                    //   icon: "assets/dashboard/ic_gallery_db.svg",
                    //   label: 'Audio',
                    //   size: '3.2 GB',
                    //   color: const Color(0xFF3273FD),
                    //   onTap: () {
                    //    // navigate with material
                    //     context.go(AppRouter.success);
                    //   },
                    // ),
                  ],
                ),
                SizedBox(height: 20),
                _buildCategoryButton(
                  icon: "assets/dashboard/ic_contact_db.svg",
                  label: localizations.contacts,
                  size: contactProvider.formattedSize,
                  color: Theme.of(context).primaryColor,
                  onTap: () {
                    context.push(AppRouter.duplicateContacts);
                  },
                ),
                // SizedBox(height: 30),
                // Provider.of<PremiumProvider>(context).isSubscribe
                //     ? SizedBox.shrink()
                //     : Container(child: _buildAdWidget()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButton({
    required String icon,
    required String label,
    required String size,
    required Color color,
    required VoidCallback onTap,
  }) {
    return _AnimatedCategoryCard(
      icon: icon,
      label: label,
      size: size,
      color: color,
      onTap: onTap,
    );
  }
}

class _AnimatedCategoryCard extends StatefulWidget {
  final String icon;
  final String label;
  final String size;
  final Color color;
  final VoidCallback onTap;

  const _AnimatedCategoryCard({
    required this.icon,
    required this.label,
    required this.size,
    required this.color,
    required this.onTap,
  });

  @override
  State<_AnimatedCategoryCard> createState() => _AnimatedCategoryCardState();
}

class _AnimatedCategoryCardState extends State<_AnimatedCategoryCard> {
  bool _isPressed = false;

  void _onTapDown(_) => setState(() => _isPressed = true);

  void _onTapUp(_) => setState(() => _isPressed = false);

  void _onTapCancel() => setState(() => _isPressed = false);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: (details) {
        _onTapUp(details);
        widget.onTap();
      },
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          height: 80,
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Color(0xff292B2B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[700]!),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage('assets/png/contact.png'),
                  ),
                ),
                padding: EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 7.0, top: 4),
                  child: SvgPicture.asset(
                    "assets/svg/contacts.svg",

                    // color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.label,
                      style: const TextStyle(
                        fontFamily: 'Gilroy',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.size,
                      style: TextStyle(
                        fontFamily: 'Gilroy',
                        color: AppColors.grayText,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
