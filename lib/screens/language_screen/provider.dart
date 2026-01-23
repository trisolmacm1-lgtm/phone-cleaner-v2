import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  int _selectedIndex = -1; // Default to first language
  static const String _languageKey = 'selected_language';
  static const String _languageIndexKey = 'selected_language_index';

  Locale _locale = const Locale('en');
  String _selectedLanguage = 'default';

  int get selectedIndex => _selectedIndex;
  Locale get locale => _locale;

  final List<Locale> supportedLocales = const [
    Locale('en'),
    Locale('es'),
    Locale('zh'),
    Locale('it'),
    Locale('fr'),
    Locale('de'),
    Locale('hi'),
    Locale('ar'),
  ];

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    final languageCode = prefs.getString(_languageKey) ?? 'en';
    final index = prefs.getInt(_languageIndexKey) ?? -1;

    _locale = Locale(languageCode);
    _selectedLanguage = languageCode;
    _selectedIndex = index;

    notifyListeners();
  }

  Future<void> changeLanguage() async {
    final locale = Locale(_selectedLanguage);
    if (!supportedLocales.contains(locale)) return;

    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, _selectedLanguage);
    await prefs.setInt(_languageIndexKey, _selectedIndex);
    notifyListeners();
  }

  String getCurrentLanguageCode() {
    return _locale.languageCode;
  }

  void selectLanguage(int index, String code) {
    _selectedIndex = index;
    _selectedLanguage = code;
    debugPrint('Selected language: $_selectedLanguage');
    notifyListeners();
  }
}
