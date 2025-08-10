import 'dart:async';
import 'dart:io' as os;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:tmiui/models.dart/tmi_datetime.dart';
import '../models.dart/reminder.dart';
import 'package:universal_html/html.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localPlugin =
      FlutterLocalNotificationsPlugin();
  static bool initialized = false;

  static Timer? _bgTimer;
  static final List<Reminder> _pendingReminders = [];

  /// Initialize for all platforms
  static Future<void> init() async {
    await _localPlugin.cancelAll(); // Clear any existing notifications
    if (initialized) return;
    await _initLocalNotifications();
    initialized = true;
  }

  /// Initialize for Android / Windows
  static Future<void> _initLocalNotifications() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    await _localPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _localPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const WindowsInitializationSettings windowsSettings =
        WindowsInitializationSettings(
      appName: 'TiMA',
      appUserModelId: 'com.example.tmiui',
      guid: '12345678-1234-1234-1234-123456789abc', // Replace with your GUID
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      windows: windowsSettings,
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
    );

    await _localPlugin.initialize(settings);
  }

  /// Schedule reminder for all platforms
  static Future<void> scheduleReminder(Reminder reminder) async {
    if (kIsWeb) {
      _pendingReminders.add(reminder);
      _startBgTimer();
    } else {
      var tzDateTime = tz.TZDateTime.fromMillisecondsSinceEpoch(
          tz.UTC, reminder.remindAt.getMillisecondsSinceEpoch());
      await _localPlugin.zonedSchedule(
          reminder.remindAt.hashCode,
          reminder.title,
          reminder.description,
          tzDateTime,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'reminder_channel',
              'Reminders',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
    }
  }

  /// Background timer for Web + Windows
  static void _startBgTimer() {
    _bgTimer ??= Timer.periodic(const Duration(seconds: 30), (timer) {
      final now = TmiDateTime.now();

      _pendingReminders.removeWhere((reminder) {
        final reminderTime = reminder.remindAt.getMillisecondsSinceEpoch();
        final difference =
            (reminderTime - now.getMillisecondsSinceEpoch()).abs() / 1000;

        if (difference <= 30) {
          if (kIsWeb) {
            if (Notification.supported) {
              Notification.requestPermission().then((perm) {
                if (perm == 'granted') {
                  Notification(reminder.title, body: reminder.description);
                }
              });
            }
          } else if (os.Platform.isWindows) {
            _localPlugin.show(
              reminder.remindAt.hashCode,
              reminder.title,
              reminder.description,
              const NotificationDetails(
                windows: WindowsNotificationDetails(),
              ),
            );
          }
          return true; // remove after showing
        }
        return false;
      });

      if (_pendingReminders.isEmpty) {
        _bgTimer?.cancel();
        _bgTimer = null;
      }
    });
  }

  /// Cancel a specific reminder
  static Future<void> cancelReminder(int id) async {
    if (kIsWeb || os.Platform.isWindows) {
      _pendingReminders.removeWhere((r) => r.remindAt.hashCode == id);
    } else {
      await _localPlugin.cancel(id);
    }
  }

  /// Cancel all reminders
  static Future<void> cancelAllReminders() async {
    if (kIsWeb || os.Platform.isWindows) {
      _pendingReminders.clear();
      _bgTimer?.cancel();
      _bgTimer = null;
    } else {
      await _localPlugin.cancelAll();
    }
  }
}
