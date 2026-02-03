import 'dart:io';

import 'package:go_router/go_router.dart';
import 'package:phone_cleaner_2/screens/compress_screen/compression_screen.dart';
import 'package:phone_cleaner_2/screens/home_screen/phone_cleaner_home.dart';
import 'package:phone_cleaner_2/screens/language_screen/language_screen.dart';
import 'package:phone_cleaner_2/screens/onboarding_screen/onboarding_screen.dart';
import 'package:phone_cleaner_2/screens/private_screen/private_view.dart';
import 'package:phone_cleaner_2/screens/settings_screen/theme_screen.dart';
import 'package:phone_cleaner_2/screens/smart_cleaner/smart_cleaner_screen.dart';
import 'package:phone_cleaner_2/screens/splash/splash_Screen.dart';

import '../main.dart';
import '../screens/compress_screen/compress_result.dart';
import '../screens/duplicate_contacts_screen/contacts_view.dart';
import '../screens/duplicate_image_screen/duplicate_image_screen.dart';
import '../screens/duplicate_videos_screen/duplicate_screen.dart';
import '../screens/paywall_screen/premium_unlock_screen.dart';
import '../screens/paywall_screen/subscription_success_screen.dart';
import '../screens/private_screen/image_display_view.dart';
import '../screens/private_screen/lock_screen.dart';
import '../screens/smart_cleaner/test.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    navigatorKey: rootNavigatorKey,
    routes: [
      GoRoute(path: splash, builder: (context, state) => const Splash()),
      GoRoute(
        path: language,
        builder: (context, state) => const LanguageView(),
      ),
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: dashboard,
        builder: (context, state) => const PhoneCleanerHome(),
      ),
      GoRoute(
        path: '/compression',
        name: AppRouter.compression,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return CompressionScreen(
            videoPath: extra['video'],
            thumbBytes: extra['thumb'],
          );
        },
      ),
      GoRoute(path: lock, builder: (context, state) => const PrivateLockView()),
      GoRoute(path: private, builder: (context, state) => const PrivateView()),
      GoRoute(
        path: success,
        builder: (context, state) => const SubscriptionSuccessScreen(),
      ),
      GoRoute(
        path: privatePreview,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          final String id = args["id"];
          final File image = args["image"];

          return ImageDisplayScreen(id: id, image: image);
        },
      ),
      GoRoute(
        path: smartCleaner,
        builder: (context, state) => const SmartCleanerScreen(),
      ),
      GoRoute(
        path: premium,
        builder: (context, state) => const PremiumUnlockScreen(),
      ),
      GoRoute(path: test, builder: (context, state) => const StorageScreen()),
      GoRoute(
        path: duplicateImage,
        builder: (context, state) => const DuplicateFinderScreen(),
      ),
      GoRoute(
        path: duplicateVideo,
        builder: (context, state) => const DuplicateVideoFinderScreen(),
      ),
      GoRoute(
        path: duplicateContacts,
        builder: (context, state) => DuplicateContactsScreen(),
      ),
      GoRoute(path: themescreen, builder: (context, state) => ThemeScreen()),
      GoRoute(
        path: videoResult,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return CompressResultScreen(
            // originalPath: data['originalPath'],
            compressedPath: data['compressedPath'],
            // originalSize: data['originalSize'],
            compressedSize: data['compressedSize'],
          );
        },
      ),
    ],
  );

  static const splash = '/splash';
  static const language = '/language';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const dashboard = '/dashboard';
  static const settings = '/settings';
  static const premium = '/premium';
  static const compression = '/compression';
  static const lock = '/lock';
  static const private = '/private';
  static const privatePreview = '/private-preview';
  static const smartCleaner = '/smart-cleaner';
  static const test = '/test';
  static const test1 = '/test1';
  static const duplicateImage = '/duplicate-image';
  static const duplicateVideo = '/duplicate-video';
  static const duplicateContacts = '/duplicate-contacts';
  static const duplicateAudio = '/duplicate-audio';
  static const videoResult = '/video-result';
  static const success = '/success';
  static const themescreen = '/themescreen';
}
