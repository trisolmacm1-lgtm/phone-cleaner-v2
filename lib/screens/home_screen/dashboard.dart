import 'package:flutter/material.dart';
import 'package:phone_cleaner_2/screens/compress_screen/compress_view.dart'
    hide AppLocalizations;
import 'package:phone_cleaner_2/screens/private_screen/lock_screen.dart';
import 'package:phone_cleaner_2/screens/settings_screen/settings.dart';

import '../../core/widgets/bottom_bar.dart';
import '../../l10n/generated/app_localizations.dart';
import 'home_screen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  final List<Widget> screens = const [
    HomeView(),
    CompressView(),
    PrivateLockView(),
    SettingsView(),
  ];

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Localized labels here
    final loc = AppLocalizations.of(context)!;

    final List<Map<String, dynamic>> items = [
      {
        'icon': 'assets/dashboard/home.svg',
        'selectedIcon': 'assets/dashboard/ic_home.svg',
        'label': loc.home,
      },
      {
        'icon': 'assets/dashboard/compress.svg',
        'selectedIcon': 'assets/dashboard/ic_compress.svg',
        'label': loc.compress,
      },
      {
        'icon': 'assets/dashboard/private.svg',
        'selectedIcon': 'assets/dashboard/ic_private.svg',
        'label': loc.private,
      },
      {
        'icon': 'assets/dashboard/settings.svg',
        'selectedIcon': 'assets/dashboard/ic_settings.svg',
        'label': loc.settings,
      },
    ];

    return Scaffold(
      // backgroundColor: Colors.white,
      body: screens[_selectedIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 18.0),
        child: AnimatedBottomNavBar(
          currentIndex: _selectedIndex,
          items: items,
          onTap: _onItemTapped,
        ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
