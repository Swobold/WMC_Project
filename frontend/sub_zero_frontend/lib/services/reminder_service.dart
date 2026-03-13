import 'dart:io' show Platform;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

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

    int dayForRepeat = reminderDate.day;
    if (dayForRepeat >= 29) dayForRepeat = 28;

    const reminderHour = 19;
    const reminderMinute = 0;

    final tzDate = tz.TZDateTime(
      tz.local,
      reminderDate.year,
      reminderDate.month,
      dayForRepeat,
      reminderHour,
      reminderMinute,
    );
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
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelReminder(int subId) async {
    if (!_initialized) await init();
    await _plugin.cancel(subId);
  }

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
