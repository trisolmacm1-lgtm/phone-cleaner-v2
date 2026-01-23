import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:phone_cleaner_2/core/utils/colors.dart';
import 'package:phone_cleaner_2/core/utils/responsive_sizer.dart';
import 'package:phone_cleaner_2/core/widgets/gradient_button.dart';
import 'package:phone_cleaner_2/screens/paywall_screen/paywall_provider.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../core/utils/constants.dart';
import '../../core/utils/helper_method.dart';
import '../../l10n/generated/app_localizations.dart';

class PremiumUnlockScreen extends StatefulWidget {
  const PremiumUnlockScreen({super.key});

  @override
  State<PremiumUnlockScreen> createState() => _PremiumUnlockScreenState();
}

class _PremiumUnlockScreenState extends State<PremiumUnlockScreen> {
  int _selectedPlanIndex = 0;
  bool showIcon = false;

  // Determine the theme colors
  // static const Color primaryBlue = Color(0xFFD99A02);
  // static const Color darkText = Colors.black;
  // static const Color lightText = Colors.white;

  @override
  void initState() {
    super.initState();
    // after 3 second show the icon
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        showIcon = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PremiumProvider>();
    if (provider.nextRoute != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(provider.nextRoute!);
        provider.clearRoute();
      });
    }
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // SizedBox(height: 50),
                // --- Header Image/Illustration Section ---
                _buildHeaderIllustration(context),
                // --- Unlock All Features Title & Scrollable Content ---
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 24.0, bottom: 24.0),
                        child: Text(
                          localizations.unlockAllFeatures,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).primaryColor,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),

                      // // --- Feature List ---
                      // _buildFeatureItem(
                      //   icon: "assets/dashboard/ic_ps_1.svg",
                      //   text: localizations.smartCleaning,
                      // ),
                      // _buildFeatureItem(
                      //   icon: "assets/dashboard/ic_ps_2.svg",
                      //   text: localizations.removeAllAds,
                      // ),
                      // _buildFeatureItem(
                      //   icon: "assets/dashboard/ic_ps_3.svg",
                      //   text: localizations.saveStorage,
                      // ),

                      // const SizedBox(height: 20),

                      // --- Subscription Options ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          children: [
                            // 1 Week Card (Index 0)
                            provider.availablePlans.isNotEmpty
                                ? GestureDetector(
                                    onTap: () =>
                                        setState(() => _selectedPlanIndex = 0),
                                    child: _buildSubscriptionCard(
                                      context,
                                      title: 'Weekly',
                                      price:
                                          "${provider.availablePlans[0].price}/\nWeek",
                                      details: localizations.threeDaysFreeTrial,
                                      isSelected: _selectedPlanIndex == 0,
                                      isfreetrailShow: _selectedPlanIndex == 0
                                          ? true
                                          : false,
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () =>
                                        setState(() => _selectedPlanIndex = 0),
                                    child: _buildSubscriptionCard(
                                      context,
                                      title: 'Weekly',
                                      price: '\$16.99/\nWeekly',
                                      details: 'Three Days Free Trial',
                                      isSelected: _selectedPlanIndex == 0,
                                      isfreetrailShow: _selectedPlanIndex == 0
                                          ? true
                                          : false,
                                    ),
                                  ),
                            const SizedBox(height: 10),
                            // 1 Month Card (Index 1)
                            provider.availablePlans.isNotEmpty
                                ? GestureDetector(
                                    onTap: () =>
                                        setState(() => _selectedPlanIndex = 1),
                                    child: _buildSubscriptionCard(
                                      context,
                                      title: 'Monthly',
                                      price:
                                          "${provider.availablePlans[1].price}/\nMonth",
                                      details: '50% off',
                                      isSelected: _selectedPlanIndex == 1,
                                      isfreetrailShow: false,
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () =>
                                        setState(() => _selectedPlanIndex = 1),
                                    child: _buildSubscriptionCard(
                                      context,
                                      title: 'Monthly',
                                      price: '\$9.99/\nMonth',
                                      details: '50% off',
                                      isSelected: _selectedPlanIndex == 1,
                                      isfreetrailShow: false,
                                    ),
                                  ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --- Next Button ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: CustomButtonWidget(
                          onPressed: provider.isLoading
                              ? null
                              : () async {
                                  if (provider.availablePlans.isNotEmpty) {
                                    if (_selectedPlanIndex == 0) {
                                      await provider.subscribe(
                                        provider.availablePlans[0].id,
                                      );
                                    } else if (_selectedPlanIndex == 1) {
                                      await provider.subscribe(
                                        provider.availablePlans[1].id,
                                      );
                                    }
                                  }
                                },
                          text: _selectedPlanIndex == 0
                              ? localizations.startFreeNow
                              : localizations.startNow,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFC94A), Color(0xFFFF9F1C)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: 35.0,
                          paddingVertical: 15.0,
                          elevation: 5,
                          isLoading: provider.isLoading,
                        ),
                      ),

                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            localizations.twoTapsToStart,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              _selectedPlanIndex == 0
                                  ? localizations.noPaymentNow
                                  : localizations.cancelNoCharges,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 0.0,
                          runSpacing: 0,
                          children: <Widget>[
                            _buildTextButton(
                              context,
                              localizations.restoredPurchases,
                              () {
                                // Action to restore purchase
                                debugPrint('Restore Subscription tapped');
                                provider.restorePurchases();
                                if (provider.isSubscribe && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: AppColors.bgColor,
                                      content: Text(
                                        localizations.restoredPurchases,
                                      ),
                                      duration: Duration(milliseconds: 800),
                                    ),
                                  );
                                } else {
                                  // ScaffoldMessenger.of(context).showSnackBar(
                                  //   SnackBar(
                                  //     content: Text("No Active Subscription"),
                                  //     duration: Duration(milliseconds: 800),
                                  //   ),
                                  // );
                                }
                              },
                            ),
                            _buildTextButton(
                              context,
                              localizations.privacyPolicy,
                              () {
                                _handlePrivacyPolicy(context);
                              },
                            ),
                            _buildTextButton(
                              context,
                              localizations.termsConditions,
                              () {
                                _handleTermsConditions(context);
                              },
                            ),
                          ],
                        ),
                      ),

                      // ------------------------------------------
                      // --- NEW: Disclaimer Message ---
                      // ------------------------------------------
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.0),
                        child: Text(
                          localizations.subscriptionNote,
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
            if (provider.isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.2),
                  child: Center(
                    child: Lottie.asset(
                      "assets/json/loading.json",
                      height: 100,
                      width: 100,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper method for the Feature List Items
  // Widget _buildFeatureItem({required String icon, required String text}) {
  //   // ... (This function remains the same)
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
  //     child: Row(
  //       children: <Widget>[
  //         SvgPicture.asset(icon, width: 30, height: 30),
  //         const SizedBox(width: 15),
  //         Expanded(
  //           child: Text(
  //             text,
  //             overflow: TextOverflow.ellipsis,
  //             style: const TextStyle(fontSize: 18, color: Colors.white),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // 2. Use AnimatedContainer for the subscription cards.
  Widget _buildSubscriptionCard(
    BuildContext context, {
    required String title,
    required String price,
    required String details,
    required bool isSelected,
    required bool isfreetrailShow,
  }) {
    final theme = Theme.of(context);

    // AnimatedContainer provides smooth transitions for changes in decoration.
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),

      // Animation speed
      height: 80.h,
      curve: Curves.easeInOut,
      // Smooth animation curve
      decoration: BoxDecoration(
        // color,
        color: isSelected ? Theme.of(context).primaryColor : Color(0xff292B2B),

        // gradient: isSelected
        //     ? const LinearGradient(
        //         colors: [Color(0xFFFFC94A), Color(0xFFFF9F1C)],
        //         begin: Alignment.topCenter,
        //         end: Alignment.bottomCenter,
        //       )
        //     : null,
        border: isSelected ? null : Border.all(color: Colors.grey[700]!),
        borderRadius: BorderRadius.circular(18.0),
      ),
      // padding: const EdgeInsets.all(15),
      child: Stack(
        children: [
          isfreetrailShow
              ? Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 20.h,
                    width: 100.w,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey[500]!,
                          spreadRadius: 0,
                          blurRadius: 3,
                          offset: Offset(0, .5),
                        ),
                      ],
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                      ),
                    ),
                    child: SizedBox(
                      width: 80.w,
                      child: Text(
                        AppLocalizations.of(context)!.dayfree,
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                )
              : Align(alignment: Alignment.topCenter, child: SizedBox()),
          Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 18, top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      details,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                Text(
                  price,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Update the header illustration with a simple animation placeholder.
  Widget _buildHeaderIllustration(BuildContext context) {
    // In a real app, this would use an image asset (PNG/SVG)
    // for the hand, phone, and sparkle effects.
    return Stack(
      alignment: Alignment.topRight,
      children: [
        // Placeholder Container for the large illustration
        Container(
          height: 300,
          margin: EdgeInsets.only(top: 65.h),
          alignment: Alignment.center,
          color: Colors.transparent, // Background of the header is transparent
          child: Lottie.asset("assets/json/premium.json"),
        ),
        // The X/Close button
        Visibility(
          visible: showIcon,
          child: Positioned(
            top: 20,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.close, size: 24, color: Colors.white),
              onPressed: () {
                // Handle closing the screen/dialog
                if (Constants.isFromOnboarding == true) {
                  context.go(AppRouter.dashboard);
                  Constants.isFromOnboarding = false;
                } else {
                  context.go(AppRouter.dashboard);
                  Constants.isFromOnboarding = false;
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextButton(
    BuildContext context,
    String text,
    VoidCallback onPressed,
  ) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  void _handlePrivacyPolicy(BuildContext context) async {
    UrlLauncher.launchTerms(context, privacyPoliceUrl);
  }

  void _handleTermsConditions(BuildContext context) {
    UrlLauncher.launchTerms(context, termsConditionsUrl);
  }
}
