import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationPermissionStatus {
  final bool notificationsGranted;
  final bool exactAlarmGranted;

  const NotificationPermissionStatus({
    required this.notificationsGranted,
    required this.exactAlarmGranted,
  });

  bool get isFullyGranted => notificationsGranted && exactAlarmGranted;
}

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    tz_data.initializeTimeZones();
    final timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const androidSettings = AndroidInitializationSettings('ic_notification');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
    _initialized = true;
  }

  /// Requests notification + exact-alarm permissions and reports what was granted.
  /// On Android 13+ shows the POST_NOTIFICATIONS dialog; on Android 12+ also
  /// triggers the SCHEDULE_EXACT_ALARM permission flow (system dialog or
  /// settings page depending on OS version). On iOS requests alert/badge/sound.
  static Future<NotificationPermissionStatus> requestPermissions() async {
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final iosImpl = _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

    bool notifications = true;
    bool exactAlarm = true;

    if (androidImpl != null) {
      notifications = await androidImpl.requestNotificationsPermission() ?? false;
      exactAlarm = await androidImpl.requestExactAlarmsPermission() ?? false;
    }

    if (iosImpl != null) {
      final granted = await iosImpl.requestPermissions(alert: true, badge: true, sound: true);
      notifications = granted ?? false;
      // iOS doesn't have a separate exact-alarm permission.
      exactAlarm = notifications;
    }

    return NotificationPermissionStatus(
      notificationsGranted: notifications,
      exactAlarmGranted: exactAlarm,
    );
  }

  /// Schedules the daily reminder. Uses exact alarms when permitted; falls back
  /// to inexact (which Android may delay 15+ min) when the user has denied
  /// the exact-alarm permission. Returns true if scheduling succeeded.
  static Future<bool> scheduleDailyReminder(TimeOfDay time, {bool exactAlarmGranted = true}) async {
    if (!_initialized) return false;
    await cancelReminder();

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      await _plugin.zonedSchedule(
        0,
        'MoodLoom',
        'How are you feeling right now? Take a moment to log your mood 🌿',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'mood_reminder',
            'Mood Reminders',
            channelDescription: 'Daily reminders to log your mood',
            importance: Importance.high,
            priority: Priority.high,
            icon: 'ic_notification',
            color: Color(0xFFD63384),
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: exactAlarmGranted
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminder_enabled', true);
    await prefs.setInt('reminder_hour', time.hour);
    await prefs.setInt('reminder_minute', time.minute);
    return true;
  }

  /// Debug helper — returns the list of pending scheduled notifications.
  static Future<List<PendingNotificationRequest>> pendingNotifications() {
    return _plugin.pendingNotificationRequests();
  }

  static Future<void> cancelReminder() async {
    await _plugin.cancel(0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminder_enabled', false);
  }

  static Future<bool> isReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('reminder_enabled') ?? false;
  }

  static Future<TimeOfDay?> getReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('reminder_hour');
    final minute = prefs.getInt('reminder_minute');
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }
}
