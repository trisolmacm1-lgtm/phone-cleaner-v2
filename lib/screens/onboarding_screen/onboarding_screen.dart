// --- Data Structure for Onboarding Pages ---
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:phone_cleaner_2/core/routes.dart';
import 'package:phone_cleaner_2/core/utils/colors.dart';
import 'package:phone_cleaner_2/core/utils/responsive_sizer.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/constants.dart';
import '../../l10n/generated/app_localizations.dart';
import '../paywall_screen/paywall_provider.dart';

class OnboardingPageData {
  final String title;
  final String description;
  final Widget animationPlaceholder; // Use a Widget for flexibility

  OnboardingPageData({
    required this.title,
    required this.description,
    required this.animationPlaceholder,
  });
}

// --- The Main Onboarding Screen Widget ---
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late List<OnboardingPageData> _pages;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ Initialize localized page data
    final loc = AppLocalizations.of(context)!;

    _pages = [
      OnboardingPageData(
        title: loc.onb_title_1,
        //loc.smartlyRemoveDuplicates,
        description: loc.onb_subtitle_1,
        //loc.smartlyRemoveDuplicatesDesc,
        animationPlaceholder: Lottie.asset(
          "assets/json/onboarding_1.json",
          width: double.infinity,
          height: 400.h,
        ),
      ),
      OnboardingPageData(
        title: loc.onb_title_2,
        //loc.instantCleanBoost,
        description: loc.onb_subtitle_2,
        // loc.instantCleanBoostDesc,
        animationPlaceholder: Lottie.asset(
          "assets/json/onboarding_2.json",
          width: double.infinity,
          height: 400.h,
        ),
      ),
      OnboardingPageData(
        title: loc.onb_title_3,
        // loc.instantCleanBoost,
        description: loc.onb_subtitle_3,
        // loc.instantCleanBoostDesc,
        animationPlaceholder: Lottie.asset(
          "assets/json/onboarding_3.json",
          width: double.infinity,
          height: 400.h,
        ),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  // --- Widget Builders ---

  Widget _buildPageIndicator(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: _currentPage == index ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? Theme.of(context).primaryColor
            : const Color(0xFFDADADA),
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }

  Widget _buildPageContent(OnboardingPageData pageData) {
    return SafeArea(
      bottom: false,
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Animation/Image
          pageData.animationPlaceholder,

          SizedBox(height: 15.0.h),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Text(
              pageData.title,
              style: const TextStyle(
                fontSize: 26.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 5.0.h),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Text(
              pageData.description,
              style: TextStyle(fontSize: 16.0, color: Colors.grey[300]),
              textAlign: TextAlign.center,
            ),
          ),
          // const Spacer(flex: 2),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final String buttonText = _currentPage == _pages.length - 1
        ? loc.getStarted
        : loc.next;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 600.h,
            width: double.infinity,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return _buildPageContent(_pages[index]);
              },
            ),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, _buildPageIndicator),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(
                  left: 32.0,
                  right: 32.0,
                  bottom: 20.0,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeIn,
                        );
                      } else {
                        Constants.isFromOnboarding = true;
                        await prefs.setBool('onboarding_completed', true);
                        if (Provider.of<PremiumProvider>(
                          context,
                          listen: false,
                        ).isSubscribe) {
                          context.go(AppRouter.dashboard);
                        } else {
                          context.go(AppRouter.premium);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
