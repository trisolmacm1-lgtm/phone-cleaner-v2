import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_cleaner_2/core/routes.dart';
import 'package:phone_cleaner_2/core/utils/constants.dart';
import 'package:phone_cleaner_2/core/utils/helper_method.dart';
import 'package:phone_cleaner_2/core/utils/responsive_sizer.dart';
import 'package:phone_cleaner_2/screens/home_screen/widget/square_precentage.dart';
import 'package:phone_cleaner_2/screens/settings_screen/theme_provider.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../screens/smart_cleaner/provider.dart';

class StorageUsageCard extends StatelessWidget {
  const StorageUsageCard({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageProvider>();
    final localizations = AppLocalizations.of(context)!;
    final theme = context.watch<ThemeProvider>().theme;

    final usedPercent = (storage.used / storage.total).clamp(0.0, 1.0);
    return Container(
      width: double.infinity,
      height: 200.h,
      // padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          fit: BoxFit.fill,
          image: AssetImage(theme.assets.background),
          // image: AssetImage('assets/png/main_img.png'),
        ),
      ),
      child: Stack(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text('${Theme.of(context).primaryColor}'),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 20.0.w),
              child: SquareProgressIndicator(
                targetValue: usedPercent,
                size: 140,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 40.0, right: 16),
              child: Container(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 155.w,
                      child: Text(
                        localizations.storageUsage,
                        style: TextStyle(
                          fontFamily: 'GilroyBold',
                          fontSize: 22.fSize,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 155.w,
                      child: Text(
                        "${storage.used.toStringAsFixed(1)}/ ${storage.total.toStringAsFixed(0)}GB ${localizations.used}",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "GilroyBold",
                          fontSize: 18.fSize,
                          // fontWeight: FontWeight.w900,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Text('data'),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 25.0, bottom: 22),
              child: InkWell(
                onTap: () {
                  ClickDelay.run(() {
                    Constants.isInterSplash = true;
                    if (storage.isPermissionGranted) {
                      context.push(AppRouter.smartCleaner);
                      Constants.isInterSplash = false;
                    } else {
                      storage.requestPermission(context);
                    }
                  });
                },
                child: Container(
                  width: 130.w,
                  height: 30.h,
                  decoration: BoxDecoration(
                    color: Color(0xff292B2B),
                    // Color(0xff292B2B),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 90,
                        color: Colors.transparent,
                        child: Text(
                          AppLocalizations.of(context)!.smartclean,
                          style: TextStyle(
                            fontFamily: "GilroyBold",
                            color: Colors.white,
                            fontSize: 14.fSize,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 10),
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 10.adaptSize,
                        child: Center(
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14.adaptSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
