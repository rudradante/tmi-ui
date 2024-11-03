import 'package:flutter/material.dart';
import 'package:tmiui/models.dart/tmi_datetime.dart';

extension TimeOfDayExtension on TimeOfDay {
  int compareTo(TimeOfDay other) {
    if (hour < other.hour) return -1;
    if (hour > other.hour) return 1;
    if (minute < other.minute) return -1;
    if (minute > other.minute) return 1;
    return 0;
  }

  static TimeOfDay fromJson(Map<String, dynamic> json) {
    return TimeOfDay(hour: json['hour'], minute: json['minute']);
  }

  Map<String, int> toJson() {
    return {'hour': hour, 'minute': minute};
  }

  String toAmPm() {
    return TmiDateTime.fromTimeOfDay(this).getTimeAsString();
  }

  static TimeOfDay fromMillisecondsSinceEpoch(int ms) {
    return TmiDateTime(ms).toTimeOfDay();
  }
}
