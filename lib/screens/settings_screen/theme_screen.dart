import 'package:flutter/material.dart';
import 'package:phone_cleaner_2/core/utils/colors.dart';
import 'package:phone_cleaner_2/core/utils/responsive_sizer.dart';
import 'package:phone_cleaner_2/core/widgets/gradient_button.dart';
import 'package:phone_cleaner_2/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

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

                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedTheme = type);
                    },
                    child: Column(
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
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
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
