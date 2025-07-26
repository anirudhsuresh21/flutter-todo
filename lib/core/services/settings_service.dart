import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _themeKey = 'theme_mode';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _syncIntervalKey = 'sync_interval';
  static const String _firstLaunchKey = 'first_launch';
  static const String _languageKey = 'language';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Theme settings
  static Future<void> setThemeMode(String themeMode) async {
    await _prefs?.setString(_themeKey, themeMode);
  }

  static String getThemeMode() {
    return _prefs?.getString(_themeKey) ?? 'system';
  }

  // Notifications
  static Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs?.setBool(_notificationsKey, enabled);
  }

  static bool getNotificationsEnabled() {
    return _prefs?.getBool(_notificationsKey) ?? true;
  }

  // Sync interval (in minutes)
  static Future<void> setSyncInterval(int minutes) async {
    await _prefs?.setInt(_syncIntervalKey, minutes);
  }

  static int getSyncInterval() {
    return _prefs?.getInt(_syncIntervalKey) ?? 15; // Default 15 minutes
  }

  // First launch flag
  static Future<void> setFirstLaunch(bool isFirst) async {
    await _prefs?.setBool(_firstLaunchKey, isFirst);
  }

  static bool isFirstLaunch() {
    return _prefs?.getBool(_firstLaunchKey) ?? true;
  }

  // Language
  static Future<void> setLanguage(String languageCode) async {
    await _prefs?.setString(_languageKey, languageCode);
  }

  static String getLanguage() {
    return _prefs?.getString(_languageKey) ?? 'en';
  }

  // Clear all settings
  static Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
