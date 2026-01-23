import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_cleaner_2/core/routes.dart';
import 'package:phone_cleaner_2/core/utils/colors.dart';
import 'package:phone_cleaner_2/core/utils/responsive_sizer.dart';
import 'package:phone_cleaner_2/core/widgets/gradient_button.dart';
import 'package:phone_cleaner_2/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../paywall_screen/paywall_provider.dart';
import 'theme_provider.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  late AppThemeType selectedTheme;

  @override
  void initState() {
    super.initState();
    selectedTheme = context.read<ThemeProvider>().themeType;
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = context.watch<ThemeProvider>().theme;
    final provider = AppLocalizations.of(context)!;

    // TODO: Replace this with your actual Premium/Subscription provider logic
    // Example: final isUserPremium = context.watch<SubscriptionProvider>().isPremium;
    bool isUserPremium = Provider.of<PremiumProvider>(
      context,
      listen: false,
    ).isSubscribe;

    final themes = [
      {'name': provider.defaultColor, 'type': AppThemeType.defaultTheme},
      {'name': provider.blue, 'type': AppThemeType.blue},
      {'name': provider.purple, 'type': AppThemeType.purple},
      {'name': provider.orange, 'type': AppThemeType.orange},
      {'name': provider.green, 'type': AppThemeType.green},
      {'name': provider.red, 'type': AppThemeType.red},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.theme),
        leading: InkWell(
          borderRadius: BorderRadius.circular(90),
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        backgroundColor: AppColors.bgColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                itemCount: themes.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemBuilder: (context, index) {
                  final AppThemeType type =
                      themes[index]['type'] as AppThemeType;

                  final String name = themes[index]['name'] as String;

                  // Convert enum → actual theme
                  final AppTheme theme = AppThemeMapper.fromType(type);

                  final bool isSelected = selectedTheme == type;

                  // --- 👑 PREMIUM LOGIC ---
                  // 1. First theme (index 0) is free, others are premium
                  final bool isPremiumTheme = index != 0;

                  // 2. Is it locked for this user?
                  final bool isLocked = isPremiumTheme && !isUserPremium;

                  return GestureDetector(
                    onTap: () {
                      // --- 🔒 CHECK LOCK STATUS ---
                      if (isLocked) {
                        context.go(AppRouter.premium);
                        return;
                      }

                      setState(() => selectedTheme = type);
                    },
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 70.w,
                              height: 70.h,
                              decoration: BoxDecoration(
                                color: theme.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? currentTheme.primaryColor
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              // Display Check if selected, otherwise display Lock if locked
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white)
                                  : (isLocked
                                        ? const Icon(
                                            Icons.lock_outline,
                                            color: Colors.white54,
                                          )
                                        : null),
                            ),

                            // Optional: Add a small "Crown" badge on the corner for premium themes
                            if (isLocked)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.amber,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.workspace_premium, // Crown icon
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 70.w,
                          color: Colors.transparent,
                          alignment: Alignment.center,
                          child: Text(
                            name,
                            style: const TextStyle(color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            /// ✅ SAVE BUTTON
            CustomButtonWidget(
              onPressed: () {
                context.read<ThemeProvider>().changeTheme(selectedTheme);
                Navigator.pop(context);
              },
              text: provider.saveImage.split(' ').first,
              gradient: LinearGradient(
                colors: [currentTheme.primaryColor, currentTheme.primaryColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: 35.0,
              paddingVertical: 15.0,
              elevation: 5,
            ),
          ],
        ),
      ),
    );
  }
}
