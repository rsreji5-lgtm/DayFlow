import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tzlib;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> initialize() async {
    if (_initialized) {
      debugPrint('NotificationService already initialized.');
      return;
    }

    debugPrint('========================================');
    debugPrint('DAYFLOW NOTIFICATION SERVICE INITIALIZING');
    debugPrint('========================================');

    tz.initializeTimeZones();

    try {
      const channel = MethodChannel('dayflow/native_timezone');
      final String nativeTimeZone =
          await channel.invokeMethod<String>('getLocalTimezone') ??
              'Asia/Kolkata';
      debugPrint('Native timezone: $nativeTimeZone');
      tzlib.setLocalLocation(tzlib.getLocation(nativeTimeZone));
      debugPrint('Notification timezone set to: ${tzlib.local.name}');
    } catch (e) {
      debugPrint('Could not get native timezone: $e');
      debugPrint('Falling back to Asia/Kolkata.');
      tzlib.setLocalLocation(tzlib.getLocation('Asia/Kolkata'));
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    final initialized = await _notifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('Notification clicked.');
        debugPrint('Payload: ${response.payload}');
      },
    );

    debugPrint('Notifications initialized: $initialized');

    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    final notificationPermission =
        await android?.requestNotificationsPermission();
    debugPrint('Notification permission: $notificationPermission');

    final exactAlarmPermission = await android?.requestExactAlarmsPermission();
    debugPrint('Exact alarm permission: $exactAlarmPermission');

    final canScheduleExact = await android?.canScheduleExactNotifications();
    debugPrint('Can schedule exact notifications: $canScheduleExact');

    const channel = AndroidNotificationChannel(
      'dayflow_tasks',
      'DayFlow Task Reminders',
      description: 'Notifications for DayFlow task reminders',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await android?.createNotificationChannel(channel);

    debugPrint('Notification channel created successfully.');

    _initialized = true;

    debugPrint('========================================');
    debugPrint('DAYFLOW NOTIFICATION SERVICE READY');
    debugPrint('========================================');
  }

  NotificationDetails _notificationDetails({String? ticker}) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'dayflow_tasks',
        'DayFlow Task Reminders',
        channelDescription: 'Notifications for DayFlow task reminders',
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        fullScreenIntent: true,
        playSound: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
        autoCancel: true,
        showWhen: true,
        when: DateTime.now().millisecondsSinceEpoch,
        ticker: ticker ?? 'DayFlow Reminder',
        styleInformation: const BigTextStyleInformation(''),
      ),
    );
  }

  Future<void> showImmediateTestNotification() async {
    try {
      debugPrint('----------------------------------------');
      debugPrint('DAYFLOW IMMEDIATE NOTIFICATION TEST');
      debugPrint('----------------------------------------');

      await _notifications.show(
        id: 999,
        title: '⏰ DayFlow Test',
        body: 'Immediate notification is working! Tap to open DayFlow.',
        notificationDetails: _notificationDetails(ticker: 'DayFlow immediate test'),
        payload: 'immediate_test',
      );

      debugPrint('SUCCESS: Immediate notification fired.');
    } catch (e, stackTrace) {
      debugPrint('IMMEDIATE NOTIFICATION ERROR: $e');
      debugPrint(stackTrace.toString());
    }
  }

  /// Schedules a test notification 30 seconds from now.
  /// Use this to verify timed notifications work without waiting hours.
  Future<void> scheduleTestIn30Seconds() async {
    try {
      final reminderTime = DateTime.now().add(const Duration(seconds: 30));
      debugPrint('Scheduling test notification for: $reminderTime');
      await scheduleTaskReminder(
        notificationId: 998,
        taskTitle: 'DayFlow 30-second test reminder 🎉',
        reminderTime: reminderTime,
      );
      debugPrint('Test notification scheduled for 30 seconds from now.');
    } catch (e, stackTrace) {
      debugPrint('TEST SCHEDULE ERROR: $e');
      debugPrint(stackTrace.toString());
    }
  }


  Future<void> scheduleTaskReminder({
    required int notificationId,
    required String taskTitle,
    required DateTime reminderTime,
  }) async {
    try {
      debugPrint('----------------------------------------');
      debugPrint('DAYFLOW SCHEDULE REQUEST');
      debugPrint('----------------------------------------');

      final now = DateTime.now();
      debugPrint('Current time: $now');
      debugPrint('Reminder time: $reminderTime');
      debugPrint('Difference: ${reminderTime.difference(now)}');

      if (!reminderTime.isAfter(now)) {
        debugPrint('Reminder NOT scheduled because the time is in the past.');
        return;
      }

      final scheduledDate = tzlib.TZDateTime.from(reminderTime, tzlib.local);

      debugPrint('Timezone: ${tzlib.local.name}');
      debugPrint('Scheduled TZDateTime: $scheduledDate');
      debugPrint('Scheduled timezone: ${scheduledDate.location}');

      try {
        await _notifications.zonedSchedule(
          id: notificationId,
          title: 'Task Reminder ⏰',
          body: taskTitle,
          scheduledDate: scheduledDate,
          notificationDetails: _notificationDetails(),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: 'task_reminder:$notificationId',
        );
      } catch (e) {
        debugPrint('Exact alarm failed ($e), falling back to inexact schedule.');
        await _notifications.zonedSchedule(
          id: notificationId,
          title: 'Task Reminder ⏰',
          body: taskTitle,
          scheduledDate: scheduledDate,
          notificationDetails: _notificationDetails(),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: 'task_reminder:$notificationId',
        );
      }

      debugPrint('SUCCESS: Notification scheduled.');

      final pending = await _notifications.pendingNotificationRequests();
      debugPrint('Pending notification count: ${pending.length}');
      for (final notification in pending) {
        debugPrint('Pending ID: ${notification.id}');
        debugPrint('Pending title: ${notification.title}');
        debugPrint('Pending body: ${notification.body}');
      }

      debugPrint('----------------------------------------');
    } catch (e, stackTrace) {
      debugPrint('SCHEDULE NOTIFICATION ERROR: $e');
      debugPrint(stackTrace.toString());
    }
  }

  Future<void> cancelTaskReminder(int notificationId) async {
    try {
      await _notifications.cancel(id: notificationId);
      debugPrint('Cancelled notification: $notificationId');
    } catch (e) {
      debugPrint('Cancel notification error: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      debugPrint('All DayFlow notifications cancelled.');
    } catch (e) {
      debugPrint('Cancel all notifications error: $e');
    }
  }

  Future<void> showPendingNotifications() async {
    try {
      final pending = await _notifications.pendingNotificationRequests();
      debugPrint('========================================');
      debugPrint('PENDING NOTIFICATIONS: ${pending.length}');
      debugPrint('========================================');
      if (pending.isEmpty) {
        debugPrint('No pending notifications.');
      }
      for (final item in pending) {
        debugPrint('ID: ${item.id}');
        debugPrint('Title: ${item.title}');
        debugPrint('Body: ${item.body}');
        debugPrint('Payload: ${item.payload}');
        debugPrint('----------------------------------------');
      }
    } catch (e) {
      debugPrint('Pending notification error: $e');
    }
  }

  Future<void> logNotificationDiagnostics() async {
    try {
      final android = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final notificationsEnabled = await android?.areNotificationsEnabled();
      final canScheduleExact = await android?.canScheduleExactNotifications();
      final pending = await _notifications.pendingNotificationRequests();
      final active = await _notifications.getActiveNotifications();

      debugPrint('========================================');
      debugPrint('DAYFLOW NOTIFICATION DIAGNOSTICS');
      debugPrint('========================================');
      debugPrint('Notifications enabled: $notificationsEnabled');
      debugPrint('Can schedule exact notifications: $canScheduleExact');
      debugPrint('Timezone: ${tzlib.local.name}');
      debugPrint('Pending notifications: ${pending.length}');
      debugPrint('Active notifications: ${active.length}');
      debugPrint('========================================');
      for (final item in pending) {
        debugPrint(
          'Pending -> ID: ${item.id}, '
          'Title: ${item.title}, '
          'Body: ${item.body}',
        );
      }
    } catch (e) {
      debugPrint('Notification diagnostics error: $e');
    }
  }

  Future<bool> areNotificationsEnabled() async {
    try {
      final android = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await android?.areNotificationsEnabled() ?? false;
    } catch (e) {
      debugPrint('Notification permission check error: $e');
      return false;
    }
  }
}
