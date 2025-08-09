import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:tmiui/models.dart/tmi_datetime.dart';

import '../models.dart/reminder.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localPlugin =
      FlutterLocalNotificationsPlugin();
  static bool initialized = false;

  /// Initialize for all platforms
  static Future<void> init() async {
    if (!initialized) {
      if (kIsWeb) {
        AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
          print("{erm aalowed: " + isAllowed.toString());
          if (!isAllowed) {
            AwesomeNotifications().requestPermissionToSendNotifications();
          }
        });
        _initAwesomeNotifications();
      } else {
        _initLocalNotifications();
      }
      initialized = true;
    }
  }

  /// Initialize for Android/iOS/macOS
  static Future<void> _initLocalNotifications() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: null,
      macOS: null,
    );
    await _localPlugin.initialize(settings);
  }

  /// Initialize for Web
  static void _initAwesomeNotifications() {
    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Reminders',
          channelDescription: 'Reminders and alerts',
          defaultColor: Colors.teal,
          importance: NotificationImportance.High,
        )
      ],
      debug: true,
    );
  }

  /// Schedule notification based on platform
  static Future<void> scheduleReminder(Reminder reminder) async {
    if (kIsWeb) {
      final duration = Duration(
          milliseconds: reminder.remindAt.getMillisecondsSinceEpoch() -
              TmiDateTime.now().getMillisecondsSinceEpoch());

      if (duration.isNegative) return; // skip past reminders

      Future.delayed(duration, () {
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: reminder.remindAt.hashCode,
            channelKey: 'basic_channel',
            title: reminder.title,
            body: reminder.description,
          ),
        );
      });
    } else {
      await _localPlugin.zonedSchedule(
          reminder.remindAt.hashCode,
          reminder.title,
          reminder.description,
          tz.TZDateTime.from(reminder.remindAt.toDateTime(), tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails('reminder_channel', 'Reminders',
                importance: Importance.max),
          ),
          matchDateTimeComponents: DateTimeComponents.dateAndTime,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
    }
  }
}
