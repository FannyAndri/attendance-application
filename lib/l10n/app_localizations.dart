import 'package:flutter/material.dart';

/// Lightweight EN / ID strings tied to [SettingsProvider.language] via [locale].
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;
  bool get _id => locale.languageCode == 'id';

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('id'),
  ];

  // Splash / branding
  String get appTitle => _id ? 'Absensi Karyawan' : 'Employee Attendance';
  String get appSubtitle =>
      _id ? 'Sistem absensi berbasis lokasi' : 'Location-based attendance system';

  // Home
  String get employeePortal => _id ? 'Portal Karyawan' : 'Employee Portal';
  String get navAttendance => _id ? 'Absensi' : 'Attendance';
  String get navWfh => 'WFH';
  String get navTracking => _id ? 'Pelacakan' : 'Tracking';
  String get navAnomalies => _id ? 'Anomali' : 'Anomalies';
  String get drawerShift => _id ? 'Shift & Lembur' : 'Shift & Overtime';
  String get drawerHistory => _id ? 'Riwayat Absensi' : 'Attendance History';
  String get drawerSettings => _id ? 'Pengaturan' : 'Settings';
  String get drawerLogout => _id ? 'Keluar' : 'Logout';

  // Settings hub
  String get settingsTitle => _id ? 'Pengaturan' : 'Settings';
  String get settingsSectionAccount => _id ? 'AKUN' : 'ACCOUNT';
  String get settingsProfile => _id ? 'Informasi profil' : 'Profile Information';
  String get settingsProfileSubtitle => _id ? 'Lihat detail profil Anda' : 'View your profile details';
  String get settingsPassword => _id ? 'Ubah kata sandi' : 'Change Password';
  String get settingsPasswordSubtitle => _id ? 'Perbarui kata sandi akun' : 'Update your account password';
  String get settingsSectionPrefs => _id ? 'PREFERENSI' : 'PREFERENCES';
  String get settingsNotifications => _id ? 'Notifikasi' : 'Notifications';
  String get settingsNotificationsSubtitle =>
      _id ? 'Kelola pengingat dan peringatan' : 'Manage reminders and alerts';
  String get settingsAppearance => _id ? 'Bahasa & tampilan' : 'Language & Appearance';
  String get settingsAppearanceSubtitle =>
      _id ? 'Bahasa, tema, dan mode gelap' : 'Language, theme, and dark mode';

  // Appearance
  String get appearanceTitle => _id ? 'Bahasa & tampilan' : 'Language & Appearance';
  String get appearanceSectionTheme => _id ? 'TAMPILAN' : 'APPEARANCE';
  String get darkMode => _id ? 'Mode gelap' : 'Dark Mode';
  String get darkModeOn => _id ? 'Tema gelap aktif' : 'Dark theme active';
  String get darkModeOff => _id ? 'Tema terang aktif' : 'Light theme active';
  String get appearanceSectionLang => _id ? 'BAHASA' : 'LANGUAGE';
  String languageChanged(String name) =>
      _id ? 'Bahasa diubah ke $name' : 'Language changed to $name';

  // Notifications screen
  String get notificationsTitle => _id ? 'Notifikasi' : 'Notifications';
  String get notifSectionAttendance => _id ? 'ABSENSI' : 'ATTENDANCE';
  String get notifCheckInTitle => _id ? 'Pengingat masuk' : 'Check-In Reminder';
  String get notifCheckInSubtitle =>
      _id ? 'Diingatkan untuk check-in tepat waktu' : 'Get reminded to check-in on time';
  String get notifCheckOutTitle => _id ? 'Pengingat pulang' : 'Check-Out Reminder';
  String get notifCheckOutSubtitle =>
      _id ? 'Diingatkan sebelum shift berakhir' : 'Reminded before your shift ends';
  String get notifSectionRequests => _id ? 'PERMOHONAN' : 'REQUESTS';
  String get notifWfhTitle => _id ? 'Update WFH' : 'WFH Status Updates';
  String get notifWfhSubtitle =>
      _id ? 'Saat WFH disetujui/ditolak' : 'Notify when WFH is approved/rejected';
  String get notifOtTitle => _id ? 'Persetujuan lembur' : 'Overtime Approval';
  String get notifOtSubtitle =>
      _id ? 'Saat lembur disetujui' : 'Notify when overtime is approved';
  String get notifSectionSecurity => _id ? 'KEAMANAN' : 'SECURITY';
  String get notifAnomalyTitle => _id ? 'Peringatan anomali' : 'Anomaly Alerts';
  String get notifAnomalySubtitle =>
      _id ? 'Jika aktivitas mencurigakan terdeteksi' : 'Alert if suspicious activity is detected';
  String get notifInfoBanner =>
      _id
          ? 'Preferensi disimpan otomatis. Izinkan notifikasi di perangkat untuk pengingat harian.'
          : 'Preferences save automatically. Allow notifications on your device for daily reminders.';
  String get notifPermissionButton =>
      _id ? 'Izinkan notifikasi' : 'Allow notifications';

  // Profile
  String get profileTitle => _id ? 'Informasi profil' : 'Profile Information';
  String get profileDeptUnknown => _id ? 'Belum diatur' : 'Not set';
  String get profileRoleEmployee => _id ? 'karyawan' : 'employee';

  // Change password
  String get changePasswordTitle => _id ? 'Ubah kata sandi' : 'Change Password';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'id'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
