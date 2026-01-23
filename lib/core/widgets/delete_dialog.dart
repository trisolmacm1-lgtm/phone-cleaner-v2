import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomActionDialog extends StatelessWidget {
  final String iconPath; // SVG asset path
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onPressed;

  const CustomActionDialog({
    super.key,
    required this.iconPath,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      elevation: 0,
      backgroundColor: Colors.black,

      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.transparent,
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
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     InkWell(
            //       borderRadius: BorderRadius.circular(90),
            //       onTap: () => context.pop(),
            //       child: CircleAvatar(
            //         backgroundColor: Colors.transparent,
            //         child: SvgPicture.asset(
            //           'assets/svg/ic_cross.svg',
            //           color: Colors.white,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 20),
            Container(
              width: 108.0,
              height: 108.0,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                //   gradient: AppColors.bgContainerGradient,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(82.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(22.0),
                child: SvgPicture.asset(iconPath),
              ),
            ),

            const SizedBox(height: 26.0),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 20.0,
                fontFamily: "Gilroy",
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 15.0),

            // Subtitle
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.0,
                fontFamily: "Gilroy",
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 15),
            //button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    // gradient: const LinearGradient(
                    //   colors: [Color(0xFF2F62FF), Color(0xFF124AF6)],
                    //   begin: Alignment.topCenter,
                    //   end: Alignment.bottomCenter,
                    // ),
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
