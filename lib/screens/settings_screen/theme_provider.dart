// import 'package:flutter/material.dart';
// import 'package:phone_cleaner_2/utils/colors.dart';

// class ThemeProvider extends ChangeNotifier {
//   AppTheme _theme = AppThemes.defaultTheme; // ✅ single source of truth

//   AppTheme get theme => _theme;

//   Color get primaryColor => _theme.primaryColor;

//   ThemeData get themeData => ThemeData(
//     brightness: Brightness.dark,
//     primaryColor: _theme.primaryColor,
//     scaffoldBackgroundColor: AppColors.bgColor,
//     colorScheme: ColorScheme.dark(primary: _theme.primaryColor),
//     appBarTheme: AppBarTheme(
//       backgroundColor: Colors.grey[900],
//       iconTheme: IconThemeData(color: _theme.primaryColor),
//       titleTextStyle: const TextStyle(
//         color: Colors.white,
//         fontSize: 18,
//         fontWeight: FontWeight.w600,
//       ),
//     ),
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: _theme.primaryColor,
//         shape: const StadiumBorder(),
//       ),
//     ),
//     floatingActionButtonTheme: FloatingActionButtonThemeData(
//       backgroundColor: _theme.primaryColor,
//     ),
//   );

//   /// ✅ Change FULL theme (color + image)
//   void changeTheme(AppTheme theme) {
//     _theme = theme;
//     notifyListeners();
//   }
// }

// class AppTheme {
//   final Color primaryColor;
//   // final String backgroundImage;
//   final ThemeAssets assets;

//   const AppTheme({required this.primaryColor, required this.assets});
// }

// class AppThemes {
//   static const defaultTheme = AppTheme(
//     primaryColor: Color(0xffDFB44F),
//     //backgroundImage: '',
//     assets: ThemeAssets(
//       background: 'assets/png/main_img.png',
//       folderIcon: 'assets/svg/upload_folder.svg',
//       uploadIcon: 'assets/svg/ic_premium.svg',
//       tickIcon: 'assets/svg/done_btn.svg',
//       cancelIcon: 'assets/svg/cancel_btn.svg',
//     ),
//   );

//   static const blueTheme = AppTheme(
//     primaryColor: Color(0xff4C8DFF),
//     assets: ThemeAssets(
//       background: 'assets/png/main_img_blue.png',
//       folderIcon: 'assets/svg/folder_blue.svg',
//       uploadIcon: 'assets/svg/blue_diamand.svg',
//       tickIcon: 'assets/svg/tick_blue.svg',
//       cancelIcon: 'assets/svg/cancel_blue.svg',
//     ),
//     // backgroundImage: 'assets/png/main_img_blue.png',
//   );

//   static const purpleTheme = AppTheme(
//     primaryColor: Color(0xff7C3AED),
//     assets: ThemeAssets(
//       background: 'assets/png/main_img_purple.png',
//       folderIcon: 'assets/svg/folder_purple.svg',
//       uploadIcon: 'assets/svg/purple_diamand.svg',
//       tickIcon: 'assets/svg/tick_purple.svg',
//       cancelIcon: 'assets/svg/cancel_purple.svg',
//     ),
//     // backgroundImage: 'assets/png/main_img_purple.png',
//   );

//   static const orangeTheme = AppTheme(
//     primaryColor: Color(0xffFB923C),
//     assets: ThemeAssets(
//       background: 'assets/png/main_img_orange.png',
//       folderIcon: 'assets/svg/folder_orange.svg',
//       uploadIcon: 'assets/svg/orange_diamand.svg',
//       tickIcon: 'assets/svg/tick_orange.svg',
//       cancelIcon: 'assets/svg/cancel_orange.svg',
//     ),
//     // backgroundImage: 'assets/png/main_img_orange.png',
//   );

//   static const greenTheme = AppTheme(
//     primaryColor: Color(0xff22C55E),
//     assets: ThemeAssets(
//       background: 'assets/png/main_img_green.png',
//       folderIcon: 'assets/svg/folder_green.svg',
//       uploadIcon: 'assets/svg/green_diamand.svg',
//       tickIcon: 'assets/svg/tick_green.svg',
//       cancelIcon: 'assets/svg/cancel_green.svg',
//     ),
//     // backgroundImage: 'assets/png/main_img_green.png',
//   );

//   static const redTheme = AppTheme(
//     primaryColor: Color(0xffEF4444),
//     assets: ThemeAssets(
//       background: 'assets/png/main_img_red.png',
//       folderIcon: 'assets/svg/folder_red.svg',
//       uploadIcon: 'assets/svg/red_diamand.svg',
//       tickIcon: 'assets/svg/tick_red.svg',
//       cancelIcon: 'assets/svg/cancel_red.svg',
//     ),
//     // backgroundImage: '',
//   );
// }

// class ThemeAssets {
//   final String background;
//   final String folderIcon;
//   final String uploadIcon;
//   final String tickIcon;
//   final String cancelIcon;

//   const ThemeAssets({
//     required this.background,
//     required this.folderIcon,
//     required this.uploadIcon,
//     required this.tickIcon,
//     required this.cancelIcon,
//   });
// }
import 'package:flutter/material.dart';
import 'package:phone_cleaner_2/core/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _themeKey = 'selected_theme';

  AppThemeType _themeType = AppThemeType.defaultTheme;
  AppTheme _theme = AppThemes.defaultTheme;

  AppTheme get theme => _theme;
  AppThemeType get themeType => _themeType;
  Color get primaryColor => _theme.primaryColor;

  ThemeData get themeData => ThemeData(
    brightness: Brightness.dark,
    primaryColor: _theme.primaryColor,
    scaffoldBackgroundColor: AppColors.bgColor,
    colorScheme: ColorScheme.dark(primary: _theme.primaryColor),
  );

  /// Load theme at app start
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);

    if (savedTheme != null) {
      _themeType = AppThemeMapper.fromString(savedTheme);
      _theme = AppThemeMapper.fromType(_themeType);
      notifyListeners();
    }
  }

  /// Change + persist theme
  Future<void> changeTheme(AppThemeType type) async {
    final prefs = await SharedPreferences.getInstance();

    _themeType = type;
    _theme = AppThemeMapper.fromType(type);

    await prefs.setString(_themeKey, type.name);
    notifyListeners();
  }
}

class AppTheme {
  final Color primaryColor;
  final ThemeAssets assets;

  const AppTheme({required this.primaryColor, required this.assets});
}

class ThemeAssets {
  final String background;
  final String folderIcon;
  final String uploadIcon;
  final String tickIcon;
  final String cancelIcon;

  const ThemeAssets({
    required this.background,
    required this.folderIcon,
    required this.uploadIcon,
    required this.tickIcon,
    required this.cancelIcon,
  });
}

class AppThemes {
  static const defaultTheme = AppTheme(
    primaryColor: Color(0xffDFB44F),
    assets: ThemeAssets(
      background: 'assets/png/main_img.png',
      folderIcon: 'assets/svg/upload_folder.svg',
      uploadIcon: 'assets/svg/ic_premium.svg',
      tickIcon: 'assets/svg/done_btn.svg',
      cancelIcon: 'assets/svg/cancel_btn.svg',
    ),
  );

  static const blueTheme = AppTheme(
    primaryColor: Color(0xff4C8DFF),
    assets: ThemeAssets(
      background: 'assets/png/main_img_blue.png',
      folderIcon: 'assets/svg/folder_blue.svg',
      uploadIcon: 'assets/svg/blue_diamand.svg',
      tickIcon: 'assets/svg/tick_blue.svg',
      cancelIcon: 'assets/svg/cancel_blue.svg',
    ),
  );

  static const purpleTheme = AppTheme(
    primaryColor: Color(0xff7C3AED),
    assets: ThemeAssets(
      background: 'assets/png/main_img_purple.png',
      folderIcon: 'assets/svg/folder_purple.svg',
      uploadIcon: 'assets/svg/purple_diamand.svg',
      tickIcon: 'assets/svg/tick_purple.svg',
      cancelIcon: 'assets/svg/cancel_purple.svg',
    ),
  );

  static const orangeTheme = AppTheme(
    primaryColor: Color(0xffFB923C),
    assets: ThemeAssets(
      background: 'assets/png/main_img_orange.png',
      folderIcon: 'assets/svg/folder_orange.svg',
      uploadIcon: 'assets/svg/orange_diamand.svg',
      tickIcon: 'assets/svg/tick_orange.svg',
      cancelIcon: 'assets/svg/cancel_orange.svg',
    ),
  );

  static const greenTheme = AppTheme(
    primaryColor: Color(0xff22C55E),
    assets: ThemeAssets(
      background: 'assets/png/main_img_green.png',
      folderIcon: 'assets/svg/folder_green.svg',
      uploadIcon: 'assets/svg/green_diamand.svg',
      tickIcon: 'assets/svg/tick_green.svg',
      cancelIcon: 'assets/svg/cancel_green.svg',
    ),
  );

  static const redTheme = AppTheme(
    primaryColor: Color(0xffEF4444),
    assets: ThemeAssets(
      background: 'assets/png/main_img_red.png',
      folderIcon: 'assets/svg/folder_red.svg',
      uploadIcon: 'assets/svg/red_diamand.svg',
      tickIcon: 'assets/svg/tick_red.svg',
      cancelIcon: 'assets/svg/cancel_red.svg',
    ),
  );
}

enum AppThemeType { defaultTheme, blue, purple, orange, green, red }

class AppThemeMapper {
  static AppTheme fromType(AppThemeType type) {
    switch (type) {
      case AppThemeType.blue:
        return AppThemes.blueTheme;
      case AppThemeType.purple:
        return AppThemes.purpleTheme;
      case AppThemeType.orange:
        return AppThemes.orangeTheme;
      case AppThemeType.green:
        return AppThemes.greenTheme;
      case AppThemeType.red:
        return AppThemes.redTheme;
      case AppThemeType.defaultTheme:
      default:
        return AppThemes.defaultTheme;
    }
  }

  static AppThemeType fromString(String value) {
    return AppThemeType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AppThemeType.defaultTheme,
    );
  }
}
