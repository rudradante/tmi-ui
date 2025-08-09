import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:tmiui/helpers/file_system.dart';
import 'package:tmiui/models.dart/plan.dart';
import 'package:tmiui/models.dart/tmi_datetime.dart';

import '../helpers/notification_service.dart';

class Reminder {
  final String title;
  final String description;
  final TmiDateTime remindAt;

  static const String filename = "__reminders.json";

  Reminder(
      {required this.title, required this.description, required this.remindAt});

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'remindAt': remindAt.getMillisecondsSinceEpoch(),
      };

  factory Reminder.fromPlan(Plan plan) => Reminder(
        title: plan.title,
        description: plan.description,
        remindAt: plan.startTime.subtract(Duration(minutes: 15)),
      );

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
        title: json['title'],
        description: json['description'],
        remindAt: TmiDateTime(json['remindAt'] as int),
      );

  static List<Reminder> loadReminders() {
    final content = AppFile.readAsString(filename);
    if (content == null) return [];
    final List data = jsonDecode(content) as List;
    return data.map((e) => Reminder.fromJson(e)).toList();
  }

  static void saveReminders(List<Reminder> reminders) {
    AppFile.writeAsString(filename, jsonEncode(reminders));
  }

  static void syncReminders(BuildContext context) async {
    var plans = await Plan.getAllPlans(null, context);
    var reminders = plans.map((e) => Reminder.fromPlan(e)).toList();
    Reminder.saveReminders(reminders);
    NotificationService.init();
    for (var reminder in reminders.where((element) =>
        element.remindAt.getMillisecondsSinceEpoch() >
        TmiDateTime.now().getMillisecondsSinceEpoch())) {
      var rem = Reminder(
          title: "Test",
          description: "S",
          remindAt: TmiDateTime.now().add(Duration(seconds: 30)));
      print("Remindr at : " + rem.remindAt.toDateTime().toString());
      NotificationService.scheduleReminder(rem);
    }
  }
}
