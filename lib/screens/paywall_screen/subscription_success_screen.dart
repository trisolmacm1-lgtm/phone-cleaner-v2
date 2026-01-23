// import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_cleaner_2/core/routes.dart';

import '../../l10n/generated/app_localizations.dart';

/// A screen to congratulate the user on upgrading to a Pro subscription.
/// Features a confetti animation and lists the new benefits.
class SubscriptionSuccessScreen extends StatefulWidget {
  const SubscriptionSuccessScreen({super.key});

  @override
  State<SubscriptionSuccessScreen> createState() =>
      _SubscriptionSuccessScreenState();
}

class _SubscriptionSuccessScreenState extends State<SubscriptionSuccessScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    // Play the confetti animation as soon as the widget is built
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        children: [
          // Background and main content
          Container(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      _buildHeader(localizations),
                      const SizedBox(height: 30),
                      _buildBenefitsCard(localizations),
                      const SizedBox(height: 34),
                      // const Spacer(),
                      _buildActionButtons(localizations),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Confetti animation layer
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 30,
              gravity: 0.2,
              emissionFrequency: 0.05,
              colors: const [
                Colors.green,
                Colors.white,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the top section with the icon and congratulations text.
  Widget _buildHeader(AppLocalizations localizations) {
    return Column(
      children: [
        CircleAvatar(
          radius: 80,
          backgroundColor: Colors.white.withOpacity(0.9),
          // Assuming you have a party popper animation
          child: Image.asset("assets/png/img_success.png", height: 78),
        ),
        const SizedBox(height: 20),
        Text(
          // Using a hardcoded string as it's not in the S file from context
          localizations.congratulations,
          style: TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          // Using a hardcoded string
          localizations.successfullyUpgraded,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 32),
        ),
        const SizedBox(height: 16),
        _buildProBadge(),
      ],
    );
  }

  /// Builds the yellow "PRO" badge.
  Widget _buildProBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD15B),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.workspace_premium_rounded, color: Color(0xFFB57500)),
          const SizedBox(width: 8),
          Text("PRO", style: TextStyle(color: const Color(0xFFB57500))),
        ],
      ),
    );
  }

  /// Builds the card listing the new Pro benefits.
  Widget _buildBenefitsCard(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            // Using a hardcoded string
            localizations.newBenefits,
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 15),
          _buildBenefitItem(localizations.unlimitedAccess),
          _buildBenefitItem(localizations.prioritySupport),
          _buildBenefitItem(localizations.advancedAnalytics),
          _buildBenefitItem(localizations.adFree),
        ],
      ),
    );
  }

  /// Builds a single row for a benefit item.
  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF63FFA4), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the action buttons at the bottom of the screen.
  Widget _buildActionButtons(AppLocalizations localizations) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () {
              // Pop the bottom sheet and navigate to home
              context.go(AppRouter.dashboard);
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white.withOpacity(1.0), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              // Using a hardcoded string
              localizations.continue_to_dashboard,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
