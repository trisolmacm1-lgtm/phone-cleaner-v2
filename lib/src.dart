import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:phone_cleaner_2/core/routes.dart';
import 'package:phone_cleaner_2/core/utils/responsive_sizer.dart';
import 'package:phone_cleaner_2/l10n/generated/app_localizations.dart';
import 'package:phone_cleaner_2/screens/language_screen/provider.dart';
import 'package:phone_cleaner_2/screens/settings_screen/theme_provider.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Consumer2<LanguageProvider, ThemeProvider>(
          builder: (context, language, themeProvider, _) {
            return MaterialApp.router(
              routerConfig: AppRouter.router,
              locale: language.locale,
              supportedLocales: language.supportedLocales,
              // from provider
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              title: 'Phone Cleaner',
              theme: themeProvider.themeData,
              debugShowCheckedModeBanner: false,
              builder: (context, child) {
                return Directionality(
                  textDirection: TextDirection.ltr,
                  child: child!,
                );
              },
            );
          },
        );
      },
    );
  }
}
