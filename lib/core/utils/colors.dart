import 'package:flutter/cupertino.dart';

class AppColors {
  static Color bgColor = Color(0xFF222222);
  static Color bgSecondry = Color(0xff292B2B);
  static Color textColor = Color(0xFF281D1B);
  static Color primaryColor = Color(0xFFFB923C);
  static Color secondoryColor = Color(0xffE1B64F);
  static Color grayText = Color(0xFFA6A6A6);
  static Color grayBg = Color(0xFFF1F2F3);
  static Color blue = Color(0xFF2056FB);

  static LinearGradient bgContainerGradient = LinearGradient(
    colors: [Color(0xFF2F62FF), Color(0xFF0B38C2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static Shader linearGradient = const LinearGradient(
    colors: <Color>[
      Color(0xFF2F62FF), // Blue
      Color(0xFF0B38C2), // Cyan
    ],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));
}
