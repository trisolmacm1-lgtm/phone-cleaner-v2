import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:phone_cleaner_2/core/utils/responsive_sizer.dart';

class BatteryOptimizerScreen extends StatefulWidget {
  const BatteryOptimizerScreen({super.key});

  @override
  State<BatteryOptimizerScreen> createState() => _BatteryOptimizerScreenState();
}

class _BatteryOptimizerScreenState extends State<BatteryOptimizerScreen> with SingleTickerProviderStateMixin{
  final Battery _battery = Battery();

  int batteryLevel = 0;
  bool isCharging = false;

  // ✅ Quick Action States
  bool powerSaver = false;
  bool darkMode = false;
  bool cleanApps = false;
  bool wifiDisabled = false;

  StreamSubscription<BatteryState>? batterySubscription;
  late AnimationController _chargingController;
  late Animation<double> _glowAnimation;
  @override
  void dispose() {
    _chargingController.dispose(); batterySubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadBatteryInfo();
    _listenBatteryChanges();
    _chargingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _glowAnimation = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(
        parent: _chargingController,
        curve: Curves.easeInOut,
      ),
    );
    print('isCharging $isCharging');
    // Start animation if charging
    if (isCharging) {
      _chargingController.repeat(reverse: true);
    } else {
      _chargingController.stop();
    }

  }

  Future<void> _loadBatteryInfo() async {
    final level = await _battery.batteryLevel;
    final state = await _battery.batteryState;

    setState(() {
      batteryLevel = level;
      isCharging = state == BatteryState.charging;
    });
  }

  void _listenBatteryChanges() {
    batterySubscription = _battery.onBatteryStateChanged.listen((
      BatteryState state,
    ) {
      setState(() {
        isCharging = state == BatteryState.charging;
      });
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "Battery Optimizer",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ Battery Card
            _batteryCard(),

            const SizedBox(height: 25),

            // ✅ Quick Actions
            _sectionTitle("Quick Actions"),
            const SizedBox(height: 12),
            _quickActionsGrid(),

            const SizedBox(height: 25),

            // // Top Battery Drainers
            // _sectionTitle("Top Battery Drainers"),
            // const SizedBox(height: 12),
            // _batteryDrainersList(),
          ],
        ),
      ),
    );
  }

  // ===========================================================
  // ✅ Battery Card
  // ===========================================================
  LinearGradient getBatteryGradient(int batteryLevel) {
    if (batteryLevel >= 70) {
      return const LinearGradient(
        colors: [
          Color(0xFF1E8E3E), // Dark Green
          Color(0xFF43D854), // Light Green
        ],
      );
    } else if (batteryLevel >= 30) {
      return const LinearGradient(
        colors: [
          Color(0xFFFFC107), // Amber Yellow
          Color(0xFFFFE082), // Soft Yellow
        ],
      );
    } else {
      return const LinearGradient(
        colors: [
          Color(0xFFD32F2F), // Dark Red
          Color(0xFFFF5252), // Bright Red
        ],
      );
    }
  }

  Widget _batteryCard() {
    return AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 900),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: getBatteryGradient(batteryLevel), // ✅ Glow Effect When Charging
            boxShadow: isCharging
                ? [
              BoxShadow(
                color: Colors.greenAccent.withOpacity(
                  _glowAnimation.value,
                ),
                blurRadius: 25,
                spreadRadius: 2,
              ),
            ]
                : [],
          ),
          child: Row(
            children: [
              // Left Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Battery Level",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),

                    const SizedBox(height: 0),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "$batteryLevel%",
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        // Right Battery Icon
                        AnimatedScale(
                          scale: isCharging ? 1.15 : 1,
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOut,
                          child: Container(
                            width: 65.w,
                            height: 65.h,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.75),
                              borderRadius: BorderRadius.circular(23),
                            ),
                            child: Icon(
                              Icons.battery_charging_full,
                              color: isCharging? const Color(0xff0CC53B):Colors.teal,
                              size: 45.fSize,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    LinearProgressIndicator(
                      value: batteryLevel / 100,
                      minHeight: 10,
                      backgroundColor: Colors.white24,
                      borderRadius: BorderRadius.circular(12),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        const SizedBox(width: 6),
                        const Text(
                          "Battery life depends on usage",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const Spacer(),
                        Icon(Icons.flash_on, color: Colors.yellowAccent, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          isCharging ? "Charging" : "Not Charging",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            ],
          ),
        );
      }
    );
  }

  // ===========================================================
  // ✅ Section Title
  // ===========================================================

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // ===========================================================
  // ✅ Quick Actions Grid
  // ===========================================================

  Widget _quickActionsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.25,
      children: [
        _actionTile(
          icon: Icons.bolt,
          title: "Power Saver",
          subtitle: "Battery Settings",
          color: Colors.blue,
          isActive: false,
          onTap: () => AppSettings.openAppSettings(
            type: AppSettingsType.batteryOptimization,
          ),
        ),

        _actionTile(
          icon: Icons.dark_mode,
          title: "Dark Mode",
          subtitle: "Display Settings",
          color: Colors.purpleAccent,
          isActive: false,
          onTap: () =>
              AppSettings.openAppSettings(type: AppSettingsType.display),
        ),

        _actionTile(
          icon: Icons.cleaning_services,
          title: "Clean Apps",
          subtitle: "Manage Storage",
          color: Colors.orange,
          isActive: false,
          onTap: () => AppSettings.openAppSettings(
            type: AppSettingsType.internalStorage,
          ),
        ),

        _actionTile(
          icon: Icons.wifi_off,
          title: "Disable WiFi",
          subtitle: "WiFi Settings",
          color: Colors.redAccent,
          isActive: false,
          onTap: () => AppSettings.openAppSettings(type: AppSettingsType.wifi),
        ),
      ],
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 40.h,
              width: 40.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================
  // ✅ Battery Drainers List
  // ===========================================================

  Widget _batteryDrainersList() {
    final apps = [
      {"name": "Facebook", "percent": 28},
      {"name": "YouTube", "percent": 22},
      {"name": "Instagram", "percent": 18},
      {"name": "WhatsApp", "percent": 15},
    ];

    return Column(
      children: apps.map((app) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey.shade800,
                child: Text(
                  app["name"].toString()[0],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app["name"].toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: (app["percent"] as int) / 100,
                      minHeight: 6,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.lightGreenAccent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "${app["percent"]}%",
                style: const TextStyle(color: Colors.orange),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
