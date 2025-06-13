// lib/notifier/locale_notifier.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleNotifier extends ChangeNotifier {
  Locale _locale = const Locale('en'); // ✅ Default to English
  Locale get locale => _locale;

  void setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
    notifyListeners();
  }

  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('locale') ?? 'en';
    _locale = Locale(langCode);
    notifyListeners();
  }
}
