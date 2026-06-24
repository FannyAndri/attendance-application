import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Local notification IDs (must stay stable for cancel/reschedule).
abstract class _NotifIds {
  static const checkIn = 401;
  static const checkOut = 402;
  static const wfh = 403;
  static const overtime = 404;
  static const anomaly = 405;
}

/// Schedules daily reminders based on saved preferences (no backend required).
class NotificationScheduler {
  NotificationScheduler._();
  static final NotificationScheduler instance = NotificationScheduler._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> ensureInitialized() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(initSettings);

    const channel = AndroidNotificationChannel(
      'attendance_reminders',
      'Attendance',
      description: 'Check-in, check-out, and request reminders',
      importance: Importance.defaultImportance,
    );

    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(channel);

    _initialized = true;
  }

  /// Android 13+ / iOS: request showing notifications when user enables toggles.
  Future<bool> ensureNotifyPermission() async {
    await ensureInitialized();
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      if (granted == false) return false;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final ok = await ios.requestPermissions(alert: true, badge: true, sound: true);
      if (ok != true) return false;
    }
    return true;
  }

  Future<void> sync({
    required bool notifCheckIn,
    required bool notifCheckOut,
    required bool notifWfh,
    required bool notifOvertime,
    required bool notifAnomaly,
  }) async {
    try {
      await ensureInitialized();

      await _plugin.cancel(_NotifIds.checkIn);
    await _plugin.cancel(_NotifIds.checkOut);
    await _plugin.cancel(_NotifIds.wfh);
    await _plugin.cancel(_NotifIds.overtime);
    await _plugin.cancel(_NotifIds.anomaly);

    final androidDetails = AndroidNotificationDetails(
      'attendance_reminders',
      'Attendance',
      channelDescription: 'Attendance-related reminders',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    if (notifCheckIn) {
      await _scheduleDaily(
        _NotifIds.checkIn,
        'Check-in reminder',
        'Remember to check in when you arrive at work.',
        8,
        45,
        details,
      );
    }
    if (notifCheckOut) {
      await _scheduleDaily(
        _NotifIds.checkOut,
        'Check-out reminder',
        'Your shift may be ending soon — check out before you leave.',
        17,
        30,
        details,
      );
    }
    if (notifWfh) {
      await _scheduleDaily(
        _NotifIds.wfh,
        'WFH requests',
        'Review pending work-from-home requests in the app.',
        9,
        0,
        details,
      );
    }
    if (notifOvertime) {
      await _scheduleDaily(
        _NotifIds.overtime,
        'Overtime',
        'Submit or review overtime if you worked extra hours.',
        18,
        0,
        details,
      );
    }
    if (notifAnomaly) {
      await _scheduleDaily(
        _NotifIds.anomaly,
        'Attendance safety',
        'Open the app to review any attendance anomalies.',
        12,
        30,
        details,
      );
    }
    } catch (e, st) {
      debugPrint('Notification sync skipped: $e\n$st');
    }
  }

  Future<void> _scheduleDaily(
    int id,
    String title,
    String body,
    int hour,
    int minute,
    NotificationDetails details,
  ) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e, st) {
      debugPrint('Notification schedule failed: $e\n$st');
    }
  }

  /// Fire once when client-side anomaly detection finds issues (best-effort).
  Future<void> showAnomalyAlertIfEnabled({
    required bool enabled,
    required String title,
    required String body,
  }) async {
    if (!enabled) return;
    await ensureInitialized();
    final androidDetails = AndroidNotificationDetails(
      'attendance_reminders',
      'Attendance',
      channelDescription: 'Attendance-related reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    await _plugin.show(
      91042,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }
}
