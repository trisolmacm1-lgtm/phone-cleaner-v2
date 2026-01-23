import 'package:flutter/material.dart';
import 'package:phone_cleaner_2/core/utils/colors.dart';
import 'package:phone_cleaner_2/screens/splash/splash_provider.dart';
import 'package:provider/provider.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<SplashProvider>().start(context);
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.asset("assets/logo.jpg", height: 150, width: 150),
            ),
          ),
        ],
      ),
    );
  }
}
