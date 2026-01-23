import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final String? iconPath; // SVG icon path (optional)
  final VoidCallback onPressed;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final List<Color> gradientColors;
  final double iconSize;
  final double spacing;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.iconPath,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.symmetric(vertical: 18),
    this.gradientColors = const [Color(0xFFE1B64F), Color(0xFFD99A02)],
    this.iconSize = 22,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // gradient: LinearGradient(
        //   colors: gradientColors,
        //   begin: Alignment.topCenter,
        //   end: Alignment.bottomCenter,
        // ),
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(borderRadius),
        // boxShadow: [
        //   BoxShadow(
        //     color: gradientColors.last.withOpacity(0.4),
        //     blurRadius: 10,
        //     offset: const Offset(0, 6),
        //   ),
        // ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconPath != null) ...[
              SvgPicture.asset(iconPath!, height: iconSize, width: iconSize),
              SizedBox(width: spacing),
            ],
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Gilroy-Bold',
                letterSpacing: 0.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final double borderRadius;
  final double paddingVertical;
  final TextStyle? textStyle;
  final Gradient gradient;
  final double elevation;
  final bool isLoading;

  const CustomButtonWidget({
    super.key,
    required this.onPressed,
    required this.text,
    this.borderRadius = 15.0,
    this.paddingVertical = 12.0,
    this.textStyle,
    required this.gradient,
    this.elevation = 5.0,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      borderRadius: BorderRadius.circular(borderRadius),
      color: Colors.transparent, // required for gradient
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),

        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: isLoading ? null : onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: paddingVertical),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      text,
                      style:
                          textStyle ??
                          const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
