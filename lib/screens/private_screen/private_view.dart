import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:phone_cleaner_2/core/utils/colors.dart';
import 'package:phone_cleaner_2/core/utils/helper_method.dart';
import 'package:phone_cleaner_2/core/utils/responsive_sizer.dart';
import 'package:phone_cleaner_2/core/widgets/gradient_button.dart';
import 'package:phone_cleaner_2/screens/private_screen/provider.dart';
import 'package:phone_cleaner_2/screens/settings_screen/theme_provider.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../core/widgets/app_bar.dart';
import '../../l10n/generated/app_localizations.dart';
// import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

class PrivateView extends StatefulWidget {
  const PrivateView({super.key});

  @override
  State<PrivateView> createState() => _PrivateViewState();
}

class _PrivateViewState extends State<PrivateView> {
  // Set<String> provider.selectedPhotoIds = {};
  final Map<String, Future<File?>> _futureCache = {};

  Future<File?> _getFuture(PrivateProvider gallery, String id) {
    return _futureCache.putIfAbsent(id, () => gallery.getThumbnail(id));
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<PrivateProvider>(context, listen: false).loadPhotos(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: CustomAppBar(
          title: AppLocalizations.of(context)!.private,
          showBackButton: true,
          showActionButton: true,
          actionIcon: "assets/svg/ic_premium.svg",
          onActionTap: () {
            context.push(AppRouter.premium);
          },
          onBackTap: () {
            // context.go(AppRouter.dashboard);
            context.pop();
          },
        ),
        body: Consumer<PrivateProvider>(
          builder: (_, gallery, __) {
            if (gallery.isLoading) {
              return Center(
                child: Lottie.asset(
                  'assets/json/loading.json',
                  width: 100,
                  height: 100,
                ),
              );
            }

            if (gallery.photoIds.isEmpty) {
              return Align(
                alignment: Alignment.topCenter,
                child: _buildNoResults(
                  () => gallery.addMultiplePhotos(context),
                  context,
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Consumer<PrivateProvider>(
                    builder: (context, provider, _) {
                      final isAllSelected = provider.isAllSelected;

                      return CheckboxListTile(
                        contentPadding: EdgeInsets.only(left: 0, right: 0),
                        title: Text(
                          isAllSelected
                              ? AppLocalizations.of(context)!.deselectAll
                              : AppLocalizations.of(context)!.selectAll,
                          style: const TextStyle(color: Colors.white),
                        ),
                        value: provider.isAllSelected,
                        checkColor: Colors.white,
                        // fillColor: WidgetStateProperty.all(
                        //   AppColors.secondoryColor,
                        // ),
                        onChanged: (_) => provider.toggleSelectAll(),
                      );
                    },
                  ),

                  //  CheckboxListTile(
                  //   title: const Text('Select All'),
                  //   value: gallery.photoIds,
                  //   onChanged: toggleSelectAll,
                  // ),
                  Expanded(
                    child: Consumer<PrivateProvider>(
                      builder: (context, provider, _) {
                        return GridView.builder(
                          itemCount: gallery.photoIds.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemBuilder: (_, i) {
                            final id = gallery.photoIds[i];
                            final isSelected = provider.selectedPhotoIds
                                .contains(id);

                            return FutureBuilder<File?>(
                              future: _getFuture(gallery, id),
                              builder: (_, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (!snapshot.hasData ||
                                    snapshot.data == null) {
                                  return const Icon(Icons.broken_image);
                                }

                                final thumb = snapshot.data!;
                                return GestureDetector(
                                  onTap: () async {
                                    if (provider.selectedPhotoIds.isNotEmpty) {
                                      // toggle selection
                                      setState(() {
                                        if (isSelected) {
                                          provider.selectedPhotoIds.remove(id);
                                        } else {
                                          provider.selectedPhotoIds.add(id);
                                        }
                                      });
                                    } else {
                                      final fullImage = await gallery
                                          .getFullImage(id);
                                      if (fullImage != null && mounted) {
                                        context.push(
                                          AppRouter.privatePreview,
                                          extra: {"id": id, "image": fullImage},
                                        );
                                      }
                                    }
                                  },
                                  onLongPress: () {
                                    setState(() {
                                      if (isSelected) {
                                        provider.selectedPhotoIds.remove(id);
                                      } else {
                                        provider.selectedPhotoIds.add(id);
                                      }
                                    });
                                  },
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          thumb,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                      ),
                                      if (isSelected)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: SvgPicture.asset(
                                            'assets/svg/check_circle.svg',
                                            width: 24,
                                            height: 24,
                                            colorFilter: ColorFilter.mode(
                                              Theme.of(context).primaryColor,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Consumer2<PrivateProvider, PrivateProvider>(
          builder: (context, gallery, provider, child) {
            return gallery.photoIds.isEmpty
                ? SizedBox()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: GradientButton(
                      text: provider.selectedPhotoIds.isNotEmpty
                          ? AppLocalizations.of(context)!.delete
                          : AppLocalizations.of(context)!.upload,
                      iconPath: provider.selectedPhotoIds.isNotEmpty
                          ? "assets/svg/btn_delete.svg"
                          : "assets/svg/ic_plus.svg",
                      spacing: 14,
                      borderRadius: 26,
                      onPressed: () {
                        if (provider.selectedPhotoIds.isNotEmpty) {
                          // delete selected
                          deleteDialogConfirmationNew(context, () async {
                            for (var id in provider.selectedPhotoIds) {
                              await gallery.deletePhoto(id);
                            }
                            setState(() {
                              provider.selectedPhotoIds.clear();
                            });
                            context.pop();
                          });
                        } else {
                          gallery.addMultiplePhotos(context);
                        }
                      },
                    ),
                  );
          },
        ),
      ),
    );
  }

  Widget _buildNoResults(void Function()? onPressed, BuildContext context) {
    final theme = context.watch<ThemeProvider>().theme;

    return Container(
      height: 350.h,
      width: 320.w,
      margin: EdgeInsets.only(top: 30),
      decoration: BoxDecoration(
        color: AppColors.bgSecondry,
        borderRadius: BorderRadius.circular(30),
        image: DecorationImage(
          fit: BoxFit.fill,
          image: AssetImage('assets/png/borders.png'),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Column(
            children: [
              Center(
                child: SvgPicture.asset(
                  theme.assets.folderIcon,
                  width: 100.w,
                  height: 100.h,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            "${AppLocalizations.of(context)!.tapToUpload}\n${AppLocalizations.of(context)!.uploadImage}",
            // 'Tap to "Upload" Button to\nUpload Images',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: SizedBox(
              width: 250.w,
              child: GradientButton(
                text: AppLocalizations.of(context)!.upload,
                iconPath: "assets/svg/ic_plus.svg",
                spacing: 12,
                borderRadius: 26,
                onPressed: onPressed!,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
