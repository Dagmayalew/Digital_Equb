import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier with ChangeNotifier {
  // Default is light theme
  late ThemeData _currentTheme;
  late Brightness _brightness;

  static const String _prefsKey = "selected_theme";

  ThemeNotifier() {
    _brightness = Brightness.light;
    _currentTheme = ThemeData.light();
    _loadTheme(); // Load saved theme on initialization
  }

  // Getter to access current theme
  ThemeData get currentTheme => _currentTheme;

  // Getter to check if current theme is dark
  Brightness get currentBrightness => _brightness;

  // Load saved theme from SharedPreferences
  Future<void> _loadTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int themeIndex = prefs.getInt(_prefsKey) ?? 0; // 0 = Light, 1 = Dark

    if (themeIndex == 1) {
      _brightness = Brightness.dark;
      _currentTheme = ThemeData.dark();
    } else {
      _brightness = Brightness.light;
      _currentTheme = ThemeData.light();
    }

    notifyListeners();
  }

  // Toggle between Light and Dark themes
  Future<void> toggleTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_brightness == Brightness.dark) {
      _brightness = Brightness.light;
      _currentTheme = ThemeData.light();
      prefs.setInt(_prefsKey, 0);
    } else {
      _brightness = Brightness.dark;
      _currentTheme = ThemeData.dark();
      prefs.setInt(_prefsKey, 1);
    }

    notifyListeners();
  }

  // Set Light Theme explicitly
  Future<void> setLightTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _brightness = Brightness.light;
    _currentTheme = ThemeData.light();
    prefs.setInt(_prefsKey, 0);
    notifyListeners();
  }

  // Set Dark Theme explicitly
  Future<void> setDarkTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _brightness = Brightness.dark;
    _currentTheme = ThemeData.dark();
    prefs.setInt(_prefsKey, 1);
    notifyListeners();
  }
}