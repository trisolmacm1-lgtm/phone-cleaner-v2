import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_cleaner_2/screens/settings_screen/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/routes.dart';
import '../../core/utils/constants.dart';
import '../paywall_screen/paywall_provider.dart';

class SplashProvider extends ChangeNotifier {
  bool _started = false;

  Future<void> start(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_started) return;
    _started = true;
    Constants.isInterSplash = true;

    Timer(const Duration(seconds: 3), () async {
      final provider = Provider.of<PremiumProvider>(context, listen: false);
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      await themeProvider.loadTheme();
      if (!context.mounted) return;
      await provider.initialize();
      if (!context.mounted) return;
      if (prefs.getBool('onboarding_completed') == true) {
        Constants.isFromOnboarding = true;
        // context.go(AppRouter.premium);
        if (provider.isSubscribe) {
          context.go(AppRouter.dashboard);
          Constants.isFromOnboarding = false;
          Constants.isInterSplash = false;
        } else {
          context.go(AppRouter.premium, extra: true);
          Constants.isFromOnboarding = false;
          Constants.isInterSplash = false;
        }
      } else {
        Constants.isFromOnboarding = true;
        context.go(AppRouter.language);
        Constants.isInterSplash = false;
      }
    });
  }

  @override
  dispose() {
    _started = false;
    super.dispose();
  }
}
