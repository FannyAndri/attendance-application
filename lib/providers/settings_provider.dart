import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_scheduler.dart';

class SettingsProvider extends ChangeNotifier {
  static const _darkModeKey = 'dark_mode';
  static const _languageKey = 'language';
  static const _notifCheckInKey = 'notif_checkin';
  static const _notifCheckOutKey = 'notif_checkout';
  static const _notifWfhKey = 'notif_wfh';
  static const _notifOvertimeKey = 'notif_overtime';
  static const _notifAnomalyKey = 'notif_anomaly';

  bool _darkMode = false;
  String _language = 'English';
  bool _notifCheckIn = true;
  bool _notifCheckOut = true;
  bool _notifWfh = true;
  bool _notifOvertime = false;
  bool _notifAnomaly = true;

  bool get darkMode => _darkMode;
  String get language => _language;
  bool get notifCheckIn => _notifCheckIn;
  bool get notifCheckOut => _notifCheckOut;
  bool get notifWfh => _notifWfh;
  bool get notifOvertime => _notifOvertime;
  bool get notifAnomaly => _notifAnomaly;

  ThemeMode get themeMode => _darkMode ? ThemeMode.dark : ThemeMode.light;

  Locale get locale {
    switch (_language) {
      case 'Bahasa Indonesia':
        return const Locale('id');
      default:
        return const Locale('en');
    }
  }

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool(_darkModeKey) ?? false;
    _language = prefs.getString(_languageKey) ?? 'English';
    _notifCheckIn = prefs.getBool(_notifCheckInKey) ?? true;
    _notifCheckOut = prefs.getBool(_notifCheckOutKey) ?? true;
    _notifWfh = prefs.getBool(_notifWfhKey) ?? true;
    _notifOvertime = prefs.getBool(_notifOvertimeKey) ?? false;
    _notifAnomaly = prefs.getBool(_notifAnomalyKey) ?? true;
    notifyListeners();
    await NotificationScheduler.instance.sync(
      notifCheckIn: _notifCheckIn,
      notifCheckOut: _notifCheckOut,
      notifWfh: _notifWfh,
      notifOvertime: _notifOvertime,
      notifAnomaly: _notifAnomaly,
    );
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  Future<void> setLanguage(String value) async {
    _language = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, value);
  }

  Future<void> setNotifCheckIn(bool v) async {
    _notifCheckIn = v;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setBool(_notifCheckInKey, v);
    await _syncNotifications();
  }

  Future<void> setNotifCheckOut(bool v) async {
    _notifCheckOut = v;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setBool(_notifCheckOutKey, v);
    await _syncNotifications();
  }

  Future<void> setNotifWfh(bool v) async {
    _notifWfh = v;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setBool(_notifWfhKey, v);
    await _syncNotifications();
  }

  Future<void> setNotifOvertime(bool v) async {
    _notifOvertime = v;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setBool(_notifOvertimeKey, v);
    await _syncNotifications();
  }

  Future<void> setNotifAnomaly(bool v) async {
    _notifAnomaly = v;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setBool(_notifAnomalyKey, v);
    await _syncNotifications();
  }

  Future<void> _syncNotifications() async {
    await NotificationScheduler.instance.sync(
      notifCheckIn: _notifCheckIn,
      notifCheckOut: _notifCheckOut,
      notifWfh: _notifWfh,
      notifOvertime: _notifOvertime,
      notifAnomaly: _notifAnomaly,
    );
  }
}
