import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:phone_cleaner_2/core/utils/colors.dart';
import 'package:phone_cleaner_2/l10n/generated/app_localizations.dart';
import 'package:phone_cleaner_2/screens/settings_screen/theme_provider.dart';
import 'package:provider/provider.dart';

import '../../screens/paywall_screen/paywall_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showActionButton;
  final String? actionIcon;
  final VoidCallback? onBackTap;
  final VoidCallback? onActionTap;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.showActionButton = true,
    this.actionIcon,
    this.onBackTap,
    this.onActionTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().theme;
    return AppBar(
      backgroundColor: AppColors.bgColor,
      elevation: 0.6,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      leading: showBackButton
          ? IconButton(
              icon: SvgPicture.asset(
                "assets/svg/ic_back.svg",
                color: Colors.white,
              ),
              onPressed: onBackTap ?? () => Navigator.pop(context),
            )
          : null,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: "Gilroy-Bold",
          color: Colors.white,
          fontSize: 17,
        ),
      ),
      actions: [
        if (actionIcon == null)
          Visibility(
            visible: showActionButton,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.check, color: Colors.white),
              onPressed: onActionTap,
            ),
          ),
        if (actionIcon != null &&
            !Provider.of<PremiumProvider>(context).isSubscribe)
          // image button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: InkWell(
              onTap: onActionTap,
              borderRadius: BorderRadius.circular(32),
              child: Container(
                height: 40,
                width: 120,
                padding: EdgeInsets.all(0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(52),
                  border: Border.all(
                    width: 1.6,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SvgPicture.asset(
                      theme.assets.uploadIcon,
                      // color: Theme.of(context).primaryColor,
                    ),
                    Text(
                      AppLocalizations.of(context)!.premium,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              //Lottie.asset("assets/json/pro_icon.json", height: 38),
            ),
          ),
      ],
    );
  }
}
