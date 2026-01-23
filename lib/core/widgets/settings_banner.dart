import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:phone_cleaner_2/core/utils/responsive_sizer.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../screens/paywall_screen/paywall_provider.dart';
import '../routes.dart';

// Separate widget for the premium upgrade container
class PremiumUpgradeContainer extends StatelessWidget {
  const PremiumUpgradeContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final provider = context.watch<PremiumProvider>();
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        // image: DecorationImage(
        //   image: AssetImage('assets/png/bg_banner.png'),
        //   fit: BoxFit.fill,
        // ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      "assets/svg/upgrade.svg",
                      height: 18,
                      width: 18,
                      color: Colors.white,
                    ),
                    SizedBox(width: 5),
                    Text(
                      localizations.premium,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                SizedBox(
                  width: 200.w,
                  child: Text(
                    localizations.unlockFullPower,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.fSize,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 5),
                SizedBox(
                  width: 200.w,
                  height: 40.h,
                  child: Text(
                    localizations.getUnlimited,
                    // textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    // overflow: TextOverflow.ellipsis,
                  ),
                ),

                SizedBox(height: 10),
                Visibility(
                  visible: !provider.isSubscribe,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push(AppRouter.premium);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: SizedBox(
                      width: 120.w,
                      child: Text(
                        localizations.upgradeNow,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          // AppColors.secondoryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            right: -3,
            top: 0,
            bottom: 0,
            // Align to the bottom edge of the Stack, helping to center it vertically if no specific height is set
            child: Lottie.asset("assets/json/setting_premium.json"),
          ),
        ],
      ),
    );
  }
}
