import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_cleaner_2/core/routes.dart';
import 'package:provider/provider.dart';

import '../../core/utils/colors.dart';
import '../../core/utils/constants.dart';
import '../../core/utils/helper_method.dart';
import '../../core/widgets/app_bar.dart';
import '../../core/widgets/settings_banner.dart';
import '../../l10n/generated/app_localizations.dart';
import '../paywall_screen/paywall_provider.dart';
import '../private_screen/lock_screen.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      // bottomNavigationBar: Provider.of<PremiumProvider>(context).isSubscribe
      //     ? null
      //     : Container(
      //         padding: const EdgeInsets.only(top: 0),
      //         child: CustomNativeAd(
      //           factoryId: AdmobNative.nativeAdFactoryIdMedium,
      //           adUnitId: AdsUnit.adUnitIdNativeApp(),
      //           height: AdmobNative.nativeAdMediumHeight,
      //         ),
      //       ),
      appBar: CustomAppBar(
        title: localizations.settings,
        showBackButton: false,
        showActionButton: false,
        actionIcon: "assets/svg/ic_premium.svg",
        onActionTap: () {
          context.push(AppRouter.premium);
        },
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Provider.of<PremiumProvider>(context).isSubscribe
                  ? SizedBox.shrink()
                  : PremiumUpgradeContainer(),
              Provider.of<PremiumProvider>(context).isSubscribe
                  ? SizedBox()
                  : SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildSectionTitle(localizations.generalSettings),
                    _buildSettingsItem(
                      context,
                      icon: 'assets/svg/ic_language.svg',
                      title: localizations.language,
                      onTap: () {
                        context.push(AppRouter.language);
                      },
                    ),
                    _buildSettingsItem(
                      context,
                      icon: 'assets/svg/theme.svg',
                      title: AppLocalizations.of(context)!.theme,
                      onTap: () {
                        context.push(AppRouter.themescreen);
                      },
                    ),
                    _buildSettingsItem(
                      context,
                      icon: "assets/dashboard/ic_private.svg",
                      title: AppLocalizations.of(context)!.private,
                      onTap:  () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PrivateLockView(),
                          ),
                        );
                      },
                    ),
                    _buildSettingsItem(
                      context,
                      icon: 'assets/svg/ic_terms.svg',
                      title: localizations.termsConditions,
                      onTap: () => _handleTermsConditions(context),
                    ),
                    _buildSettingsItem(
                      context,
                      icon: 'assets/svg/ic_privacy.svg',
                      title: localizations.privacyPolicy,
                      onTap: () => _handlePrivacyPolicy(context),
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

  Widget _buildSettingsItem(
    BuildContext context, {
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              SvgPicture.asset(
                icon,
                height: 28,
                width: 28,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).primaryColor,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontFamily: 'Gilroy',
        fontWeight: FontWeight.w700,
        color: AppColors.grayText,
      ),
    );
  }

  void _handlePrivacyPolicy(BuildContext context) async {
    UrlLauncher.launchTerms(context, privacyPoliceUrl);
  }

  void _handleTermsConditions(BuildContext context) {
    UrlLauncher.launchTerms(context, termsConditionsUrl);
  }
}
