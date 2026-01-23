import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:phone_cleaner_2/core/routes.dart';
import 'package:phone_cleaner_2/core/utils/colors.dart';
import 'package:phone_cleaner_2/core/utils/responsive_sizer.dart';
import 'package:phone_cleaner_2/screens/settings_screen/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/widgets/app_bar.dart';
import '../../l10n/generated/app_localizations.dart';

class PrivateLockView extends StatefulWidget {
  const PrivateLockView({super.key});

  @override
  State<PrivateLockView> createState() => _PrivateLockViewState();
}

class _PrivateLockViewState extends State<PrivateLockView>
    with SingleTickerProviderStateMixin {
  // --- Constants ---
  static const int _pinLength = 4;
  static const String _storageKey = "app_pin";

  // --- State ---
  String enteredPin = '';
  String? savedPin;
  String? firstEnteredPin;
  bool isConfirmingPin = false;
  bool isAnimationShow = false;
  bool isError = false;
  String errorMessage = '';

  // --- Animation ---
  late final AnimationController _controller;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _initPin();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _shakeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  Future<void> _initPin() async {
    final prefs = await SharedPreferences.getInstance();
    savedPin = prefs.getString(_storageKey);
    setState(() {});
  }

  // ------------------ PIN Logic ------------------
  void _onNumberPressed(String number) {
    // Prevent entering more digits than required
    if (enteredPin.length >= _pinLength) return;

    // Update the state to show the new digit
    setState(() {
      enteredPin += number;
    });
    HapticFeedback.lightImpact();

    // --- NEW ---
    // If the PIN length is now 4, automatically call the continue/verify function.
    if (enteredPin.length == _pinLength) {
      // A small delay provides a better user experience, letting the user see
      // the last digit appear before the next screen loads.
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          // Check if the widget is still on screen
          _onContinueTap();
        }
      });
    }
  }

  void _onDeletePressed() {
    if (enteredPin.isEmpty) return;
    setState(() => enteredPin = enteredPin.substring(0, enteredPin.length - 1));
    HapticFeedback.lightImpact();
  }

  void _onContinueTap() {
    if (enteredPin.isNotEmpty) {
      if (enteredPin.length != _pinLength) {
        _triggerErrorAnimation();
        return;
      }
      _verifyOrSetPin();
    }
  }

  Future<void> _verifyOrSetPin() async {
    final prefs = await SharedPreferences.getInstance();

    if (savedPin == null) {
      // --- New PIN setup ---
      if (!isConfirmingPin) {
        firstEnteredPin = enteredPin;
        setState(() {
          enteredPin = '';
          isConfirmingPin = true;
        });
      } else {
        // --- Confirm PIN ---
        if (enteredPin == firstEnteredPin) {
          await prefs.setString(_storageKey, enteredPin);
          setState(() => savedPin = enteredPin);
          _navigateToNext();
        } else {
          _resetPinSetupWithError();
        }
      }
    } else {
      // --- Existing PIN verification ---
      if (enteredPin == savedPin) {
        _navigateToNext();
      } else {
        _triggerErrorAnimation();
        setState(() => enteredPin = '');
      }
    }
  }

  void _resetPinSetupWithError() {
    _triggerErrorAnimation();
    setState(() {
      enteredPin = '';
      firstEnteredPin = null;
      isConfirmingPin = false;
    });
  }

  void _triggerErrorAnimation() {
    HapticFeedback.heavyImpact();
    setState(() => isError = true);
    _controller.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => isError = false);
    });
    showSnackbar(context, AppLocalizations.of(context)!.wrong_pin);
  }

  void _navigateToNext() {
    setState(() => isAnimationShow = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      context.push(AppRouter.private);
      setState(() {
        isAnimationShow = false;
        enteredPin = '';
      });
    });
  }

  String _getTitle() {
    if (savedPin == null) {
      return isConfirmingPin
          ? AppLocalizations.of(context)!.confirmPin
          : AppLocalizations.of(context)!.setPin;
    } else {
      return AppLocalizations.of(context)!.enterYourPin;
    }
  }

  // ------------------ UI ------------------
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CustomAppBar(
        title: localizations.private,
        showBackButton: false,
        showActionButton: false,
        actionIcon: "assets/svg/ic_premium.svg",
        onActionTap: () {
          context.push(AppRouter.premium);
        },
      ),
      body: isAnimationShow
          ? _buildLoadingAnimation()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  Text(
                    _getTitle(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  // It will only be visible when errorMessage is not empty
                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  Spacer(),
                  _buildPinIndicators(),
                  const Spacer(),
                  _buildNumberPad(),
                ],
              ),
            ),
    );
  }

  Widget _buildLoadingAnimation() {
    return Center(child: Lottie.asset('assets/json/animation_lock.json'));
  }

  Widget _buildPinIndicators() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final offsetX = isError
            ? math.sin(_shakeAnimation.value * math.pi * 6) * 10
            : 0.0;
        return Transform.translate(offset: Offset(offsetX, 0), child: child);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _pinLength,
          (index) => Container(
            margin: EdgeInsets.symmetric(horizontal: 10.w),
            width: 65,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey[700]!),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  index < enteredPin.length ? enteredPin[index] : '',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                isError
                    ? Container(
                        width: 40,
                        height: 2,
                        color: isError ? Colors.red : Colors.transparent,
                      )
                    : SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    final theme = context.watch<ThemeProvider>();
    final buttonSpacing = SizedBox(height: 20.h);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildNumberRow(['1', '2', '3']),
        buttonSpacing,
        _buildNumberRow(['4', '5', '6']),
        buttonSpacing,
        _buildNumberRow(['7', '8', '9']),
        buttonSpacing,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // SizedBox(width: 20.w),
            // _buildDeleteButton(),
            PressableButton(
              onPressed: _onDeletePressed,
              child: SvgPicture.asset(theme.theme.assets.cancelIcon),
            ),
            _buildNumberButton('0'),
            // _buildContinueButton(),
            PressableButton(
              onPressed: _onContinueTap,
              child: SvgPicture.asset(theme.theme.assets.tickIcon),
            ),
            // SizedBox(width: 25.w),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildNumberRow(List<String> numbers) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: numbers.map(_buildNumberButton).toList(),
  );

  Widget _buildNumberButton(String number) {
    return PressableButton(
      onPressed: () => _onNumberPressed(number),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.bgSecondry,
          border: Border.all(color: Colors.grey[700]!),
          borderRadius: BorderRadius.circular(12),
          // shape: BoxShape.,
        ),
        alignment: Alignment.center,
        child: Text(
          number,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Widget _buildDeleteButton() {
  //   return
  // }

  // Widget _buildContinueButton() {
  //   return PressableButton(
  //     onPressed: _onContinueTap,
  //     child: SvgPicture.asset(theme.assets.tickIcon),
  //   );
  // }

  void showSnackbar(BuildContext context, wrongPin) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.bgColor,
        content: Text(
          wrongPin,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
        duration: const Duration(milliseconds: 700),
      ),
    );
  }
}

// ------------------ Reusable Pressable Button ------------------
class PressableButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;

  const PressableButton({
    required this.child,
    required this.onPressed,
    super.key,
  });

  @override
  State<PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<PressableButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
