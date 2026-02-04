import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:phone_cleaner_2/core/utils/colors.dart';
import 'package:phone_cleaner_2/core/utils/responsive_sizer.dart';
import 'package:phone_cleaner_2/l10n/generated/app_localizations.dart';
import 'package:phone_cleaner_2/screens/compress_screen/compress_view.dart';
import 'package:phone_cleaner_2/screens/home_screen/home_screen.dart';
import 'package:phone_cleaner_2/screens/home_screen/battery_optimizer_screen.dart';
import 'package:phone_cleaner_2/screens/paywall_screen/paywall_provider.dart';
import 'package:phone_cleaner_2/screens/private_screen/lock_screen.dart';
import 'package:phone_cleaner_2/screens/settings_screen/settings.dart';
import 'package:provider/provider.dart';

import '../duplicate_contacts_screen/provider.dart';
import '../duplicate_image_screen/provider/duplicate_finder_provider.dart';
import '../duplicate_videos_screen/provider.dart';
import '../paywall_screen/premium_unlock_screen.dart';
import '../smart_cleaner/provider.dart';

class PhoneCleanerHome extends StatelessWidget {
  const PhoneCleanerHome({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // Dark background
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0.6,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        leading: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsView()),
            );
            // context.push();
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SvgPicture.asset(
              'assets/svg/drawer.svg',
              height: 30,
              width: 30,
            ),
          ),
        ),
        title: Text(
          localizations.phoneCleaner,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: "Gilroy-Bold",
            color: Colors.white,
            fontSize: 17,
          ),
        ),
        actions: [
          if (!Provider.of<PremiumProvider>(context).isSubscribe)
            // image button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: InkWell(
                onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context)=>PremiumUnlockScreen()));
                },
                borderRadius: BorderRadius.circular(32),
                child: Container(
                  height: 40,
                  width: 120,
                  padding: EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(52),
                    border: Border.all(
                      width: 1.6,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SvgPicture.asset('assets/svg/ic_premium.svg'),
                      Text(
                        AppLocalizations.of(context)!.premium,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                //Lottie.asset("assets/json/pro_icon.json", height: 38),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Storage Usage Card
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/png/home_img.png'),
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Storage Usage',
                          style: TextStyle(
                            fontSize: 22.fSize,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D2B45),
                          ),
                        ),
                        Consumer<StorageProvider>(
                          builder: (context,pro,child) {
                            return Text(
                              '${pro.used.toStringAsFixed(0)}/${pro.total.toStringAsFixed(0)} Used',
                              style: TextStyle(
                                fontSize: 18.fSize,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D2B45),
                              ),
                            );
                          }
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () async{
                       // final     storage = context.read<StorageProvider>();
                       //      final provider = Provider.of<DuplicateFinderProvider>(
                       //        context,
                       //        listen: false,
                       //      );
                       //      final provider1 = Provider.of<DuplicateVideoFinderProvider>(
                       //        context,
                       //        listen: false,
                       //      );
                       //      final provider2 = Provider.of<DuplicateContactsProvider>(
                       //        context,
                       //        listen: false,
                       //      );
                       //      print('albums ${provider.albums.length}');
                       //      if (provider.albums.isEmpty ||
                       //          provider1.albums.isEmpty ||
                       //          provider2.duplicateGroups.isEmpty) {
                       //      await  provider.startScan();
                       //       await provider1.startScan();
                       //        if (provider2.permissionStatus) {
                       //          await provider2.findDuplicates();
                       //        }
                       //        // provider2.findDuplicates();
                       //      }
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => HomeView(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: EdgeInsets.only(left: 8, right: 8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: const [
                              Text('Clean File'),
                              SizedBox(width: 10),
                              Icon(
                                Icons.arrow_circle_right,
                                color: Color(0xFFE5B84C),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Feature Grid
            Row(
              children: [
                Expanded(
                  child: _buildFeatureCard(
                    'Private',
                    'Keep your Files safe',
                    "assets/dashboard/ic_private.svg",
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PrivateLockView(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFeatureCard(
                    'Compress Video',
                    'Save the Storage Space',
                    "assets/dashboard/ic_compress.svg",
                    () {
                      // CompressView
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CompressView()),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Battery List Item
            InkWell(  borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BatteryOptimizerScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[700]!),
                  color: const Color(0xFF262626), // Card background
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5B84C),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.battery_charging_full,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Battery',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white38,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    String title,
    String subtitle,
    String icon,
    VoidCallback ontap,
  ) {
    return InkWell(
      onTap: ontap,   borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.only(left: 10, top: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[700]!),
          color: const Color(0xFF262626), // Card background
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE5B84C),
                borderRadius: BorderRadius.circular(14),
              ),
              child: SvgPicture.asset(icon, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.fSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(color: Colors.white38, fontSize: 10.fSize),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
