import 'dart:io' show Platform;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// Verwaltet Android-Local-Notifications für Abo-Erinnerungen.
/// Geräteabhängig – nutzt IDs aus SharedPreferences.
class ReminderService {
  static final ReminderService _instance = ReminderService._();
  factory ReminderService() => _instance;

  ReminderService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _isAndroid = false;

  static const List<int> reminderOptions = [1, 3, 7];

  Future<void> init() async {
    if (_initialized) return;
    _isAndroid = Platform.isAndroid;

    if (_isAndroid) {
      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Europe/Vienna'));

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: android);
      await _plugin.initialize(initSettings);

      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(const AndroidNotificationChannel(
            'subzero_reminders',
            'Abo-Erinnerungen',
            description: 'Erinnerungen vor Zahlungsterminen',
            importance: Importance.defaultImportance,
          ));
    }

    _initialized = true;
  }

  /// Plant eine Erinnerung für ein Abo.
  /// [subId] – Subscription-ID (wird als Notification-ID genutzt)
  /// [title] – Abo-Name
  /// [nextPaymentDate] – ISO-String z.B. "2026-03-15T00:00:00Z"
  /// [daysBefore] – 5, 15 oder 25 Tage davor
  Future<void> scheduleReminder({
    required int subId,
    required String title,
    required String nextPaymentDate,
    required int daysBefore,
  }) async {
    if (!_initialized) await init();
    if (!_isAndroid) return;

    final dt = DateTime.tryParse(nextPaymentDate);
    if (dt == null || daysBefore < 1) return;

    final reminderDate = dt.subtract(Duration(days: daysBefore));
    if (reminderDate.isBefore(DateTime.now())) return;

    final tzDate = tz.TZDateTime.from(reminderDate, tz.local);
    final daysText = daysBefore == 1 ? '1 Tag' : '$daysBefore Tage';
    await _plugin.zonedSchedule(
      subId,
      'Erinnerung: $title',
      'Zahlung in $daysText fällig',
      tzDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'subzero_reminders',
          'Abo-Erinnerungen',
          channelDescription: 'Erinnerungen vor Zahlungsterminen',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Entfernt die geplante Erinnerung für ein Abo.
  Future<void> cancelReminder(int subId) async {
    if (!_initialized) await init();
    await _plugin.cancel(subId);
  }

  /// Aktualisiert die Erinnerung (erst cancel, dann neu planen).
  Future<void> updateReminder({
    required int subId,
    required String title,
    required String nextPaymentDate,
    required int daysBefore,
  }) async {
    await cancelReminder(subId);
    if (daysBefore > 0) {
      await scheduleReminder(
        subId: subId,
        title: title,
        nextPaymentDate: nextPaymentDate,
        daysBefore: daysBefore,
      );
    }
  }
}
