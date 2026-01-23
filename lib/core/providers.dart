import 'package:phone_cleaner_2/screens/language_screen/provider.dart';
import 'package:phone_cleaner_2/screens/paywall_screen/paywall_provider.dart';
import 'package:phone_cleaner_2/screens/settings_screen/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../screens/duplicate_contacts_screen/provider.dart';
import '../screens/duplicate_image_screen/provider/duplicate_finder_provider.dart';
import '../screens/duplicate_image_screen/provider/duplicate_selection_provider.dart';
import '../screens/duplicate_videos_screen/provider.dart';
import '../screens/private_screen/provider.dart';
import '../screens/smart_cleaner/provider.dart';
import '../screens/splash/splash_provider.dart';

List<SingleChildWidget> globalProviders = [
  ChangeNotifierProvider(create: (_) => PremiumProvider()..initialize()),
  ChangeNotifierProvider(create: (_) => SplashProvider()),
  ChangeNotifierProvider(create: (_) => LanguageProvider()),
  ChangeNotifierProvider(create: (_) => PrivateProvider()),
  ChangeNotifierProvider(create: (_) => StorageProvider()),
  ChangeNotifierProvider(create: (_) => DuplicateSelectionProvider()),
  ChangeNotifierProvider(create: (_) => DuplicateFinderProvider()),
  ChangeNotifierProvider(create: (_) => DuplicateVideoFinderProvider()),
  ChangeNotifierProvider(create: (_) => DuplicateContactsProvider()),
  ChangeNotifierProvider(create: (_) => ThemeProvider()),
];
