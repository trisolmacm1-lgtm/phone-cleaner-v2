import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phone_cleaner_2/core/utils/responsive_sizer.dart';

class PermissionDialog extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final String allowButtonText;
  final String notNowButtonText;
  final VoidCallback onAllowPressed;
  final VoidCallback onNotNowPressed;

  const PermissionDialog({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.allowButtonText,
    required this.notNowButtonText,
    required this.onAllowPressed,
    required this.onNotNowPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      elevation: 0,
      backgroundColor: Colors.black,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        image: DecorationImage(
          image: AssetImage("assets/png/dialog_bg.png"),
          fit: BoxFit.cover,
          // colorFilter: ColorFilter.mode(
          //   Colors.black.withOpacity(0.6),
          //   BlendMode.dstATop,
          // ),
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10.0,
            offset: const Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // To make the card compact
        children: <Widget>[
          // Image
          //  Icon(Icons.)   Image.asset(
          //       imagePath,
          //       height: 80,
          //       fit: BoxFit.contain,
          //       color: Colors.white,
          //     ),
          const SizedBox(height: 10),
          SvgPicture.asset(
            'assets/svg/key-square.svg',
            height: 70.h,
            width: 70.w,
            fit: BoxFit.cover,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 18),
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontFamily: 'Gilroy-Bold', // Assuming you have this font
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Gilroy-Medium', // Assuming you have this font
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Buttons
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAllowPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                elevation: 0,
              ),
              child: Text(
                allowButtonText,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontFamily: 'Gilroy-Bold',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onNotNowPressed,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              child: Text(
                notNowButtonText,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade500,
                  fontFamily: 'Gilroy-Medium',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
