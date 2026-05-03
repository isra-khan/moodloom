import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _appLockEnabled = false;
  bool _hasSeenOnboarding = false;
  bool _settingsLoaded = false;

  bool get isDarkMode => _isDarkMode;
  bool get appLockEnabled => _appLockEnabled;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get settingsLoaded => _settingsLoaded;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('dark_mode') ?? false;
    _appLockEnabled = prefs.getBool('app_lock_enabled') ?? false;
    _hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    _settingsLoaded = true;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDarkMode);
    notifyListeners();
  }

  Future<void> setAppLockEnabled(bool value) async {
    _appLockEnabled = value;
    notifyListeners();
  }

  Future<void> markOnboardingComplete() async {
    if (_hasSeenOnboarding) return;
    _hasSeenOnboarding = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    notifyListeners();
  }
}
