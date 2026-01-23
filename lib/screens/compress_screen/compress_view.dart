import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_cleaner_2/core/utils/responsive_sizer.dart';
import 'package:phone_cleaner_2/screens/settings_screen/theme_provider.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../core/utils/colors.dart';
import '../../core/widgets/app_bar.dart';
import '../../core/widgets/gradient_button.dart';
import '../../l10n/generated/app_localizations.dart';
import '../private_screen/provider.dart';

class CompressView extends StatelessWidget {
  const CompressView({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the provider for loading state
    final privateProvider = context.watch<PrivateProvider>();
    final isLoading = privateProvider.isLoadingVideo; // 👈 Get loading state
    final localizations = AppLocalizations.of(context)!;
    final theme = context.watch<ThemeProvider>().theme;
    // theme.assets.folderIcon,
    return Scaffold(
      appBar: CustomAppBar(
        title: localizations.compress,
        showBackButton: false,
        showActionButton: true,
        actionIcon: "assets/svg/ic_premium.svg",
        onActionTap: () {
          context.push(AppRouter.premium);
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20.h),
              Text(
                "${AppLocalizations.of(context)!.compressVideo}\n${AppLocalizations.of(context)!.withoutLosingQuality}",
                //  'Compress Videos\nWithout Losing Quality',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'GilroyMedium',
                  fontWeight: FontWeight.bold,
                  fontSize: 16.fSize,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                "Only Mp4  File Are Supported",
                // AppLocalizations.of(context)!.withoutLosingQuality,
                // 'Only Mp4  File Are Supported',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontFamily: 'Gilroy',
                  fontSize: 10.fSize,
                ),
              ),
              SizedBox(height: 30.h),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 35.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.bgSecondry,
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/png/borders.png'),
                  ),
                  borderRadius: BorderRadius.circular(25.adaptSize),
                  // border: Border.all(color: Colors.grey[500]!),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Text(
                    //   localizations.uploadVideo,
                    //   style: TextStyle(
                    //     fontSize: 22,
                    //     fontFamily: 'Gilroy',
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    SizedBox(height: 20.h),
                    SvgPicture.asset(
                      theme.assets.folderIcon,
                      // 'assets/svg/upload_folder.svg'
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      localizations.tapChooseVideo,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.fSize,
                        fontFamily: 'Gilroy',
                        color: AppColors.grayText,
                      ),
                    ),
                    SizedBox(height: 60.h),
                    SizedBox(
                      width: 300.w,
                      height: 50.h,
                      child: isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).primaryColor,
                                strokeWidth: 3.0,
                              ),
                            )
                          : GradientButton(
                              // 👈 Show button when not loading
                              text: localizations.upload,
                              borderRadius: 40,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              iconPath: "assets/svg/ic_upload.svg",
                              onPressed: () {
                                // Access the provider without listening here, since we are using context.watch above
                                context.read<PrivateProvider>().pickVideo(
                                  context,
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
