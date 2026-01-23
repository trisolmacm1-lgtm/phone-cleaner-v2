import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_cleaner_2/core/utils/colors.dart';
import 'package:phone_cleaner_2/core/utils/constants.dart';
import 'package:phone_cleaner_2/screens/language_screen/provider.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../core/widgets/app_bar.dart';
import '../../l10n/generated/app_localizations.dart';

class LanguageItem {
  final String name;
  final String country;
  final String flagAsset;
  final String code;

  const LanguageItem({
    required this.name,
    required this.country,
    required this.flagAsset,
    required this.code,
  });
}

class LanguageView extends StatefulWidget {
  const LanguageView({super.key});

  @override
  State<LanguageView> createState() => _LanguageViewState();
}

class _LanguageViewState extends State<LanguageView> {
  // final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  final List<LanguageItem> languages = [
    LanguageItem(
      name: 'English',
      country: 'United States',
      flagAsset: 'assets/lang/us.png',
      code: 'en',
    ),
    LanguageItem(
      name: 'Spanish',
      country: 'Spain',
      flagAsset: 'assets/lang/es.png',
      code: 'es',
    ),
    LanguageItem(
      name: 'Mandarin',
      country: 'China',
      flagAsset: 'assets/lang/cn.png',
      code: 'zh',
    ),
    LanguageItem(
      name: 'French',
      country: 'France',
      flagAsset: 'assets/lang/fr.png',
      code: 'fr',
    ),
    LanguageItem(
      name: 'German',
      country: 'Germany',
      flagAsset: 'assets/lang/de.png',
      code: 'de',
    ),
    LanguageItem(
      name: 'Italian',
      country: 'Italy',
      flagAsset: 'assets/lang/it.png',
      code: 'it',
    ),
    LanguageItem(
      name: 'Hindi',
      country: 'India',
      flagAsset: 'assets/lang/in.png',
      code: 'hi',
    ),
    LanguageItem(
      name: 'Arabic',
      country: 'Saudi Arabia',
      flagAsset: 'assets/lang/sa.png',
      code: 'ar',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.bgColor,

      appBar: CustomAppBar(
        title: localizations.selectLanguage,
        showBackButton: Constants.isFromOnboarding == true ? false : true,
        showActionButton: Constants.isFromOnboarding == false ? false : true,
        onActionTap: () {
          if (Constants.isFromOnboarding == true) {
            context.go(AppRouter.onboarding);
            Constants.isFromOnboarding = false;
          } else {
            context.pop();
          }
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // List View
            Expanded(
              child: ListView.separated(
                itemCount: languages.length,
                shrinkWrap: true,
                separatorBuilder: (context, index) => SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final lang = languages[index];
                  final isSelected =
                      languageProvider.locale.languageCode == lang.code;

                  return GestureDetector(
                    onTap: () async {
                      languageProvider.selectLanguage(index, lang.code);
                      await languageProvider.changeLanguage();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Color(0xff292B2B),
                        // gradient: isSelected
                        //     ? const LinearGradient(
                        //         colors: [Color(0xFFE1B64F), Color(0xFFD99A02)],
                        //         begin: Alignment.topCenter,
                        //         end: Alignment.bottomCenter,
                        //       )
                        // : null,
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : Colors.grey[600]!,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Image.asset(lang.flagAsset, height: 40, width: 40),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
