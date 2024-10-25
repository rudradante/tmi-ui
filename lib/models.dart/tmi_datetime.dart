// ignore_for_file: unnecessary_this

import 'package:flutter/material.dart';
import 'package:tmiui/config/config_provider.dart';

class TmiDateTime {
  final int _millisecondsSinceEpoch;
  static int timeZoneOffsetMs =
      ConfigProvider.getAppConfig().timeZoneOffset * 1000;
  TmiDateTime(this._millisecondsSinceEpoch);

  static TmiDateTime fromTimeOfDay(TimeOfDay time) {
    var milliseconds = time.hour * 3600 + time.minute * 60;
    milliseconds *= 1000;
    return TmiDateTime(milliseconds);
  }

  int getMillisecondsSinceEpoch() =>
      toDateTime(applyTimeZoneOffset: false).millisecondsSinceEpoch;

  TimeOfDay toTimeOfDay() {
    var dateTime = toDateTime();
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  DateTime toDateTime({bool applyTimeZoneOffset = true}) =>
      DateTime.fromMillisecondsSinceEpoch(
          _millisecondsSinceEpoch +
              (applyTimeZoneOffset ? timeZoneOffsetMs : 0),
          isUtc: !applyTimeZoneOffset);

  String getTimeDifferenceInDuration(TmiDateTime d2) {
    String result = "";
    int minutesDifference =
        ((d2._millisecondsSinceEpoch - _millisecondsSinceEpoch) / 60000)
            .abs()
            .floor();
    if ((minutesDifference ~/ 60) > 0) {
      result += "${minutesDifference ~/ 60} Hr and ";
    } else {
      return minutesDifference < 0 ? "0 Min" : "$minutesDifference Min";
    }
    minutesDifference = minutesDifference % 60;
    if (minutesDifference > 0) {
      result += "$minutesDifference Min";
    } else {
      result = result.substring(0, result.lastIndexOf(" and"));
    }
    return result;
  }

  String getDateAsString({bool applyTimeZoneOffset = true}) {
    DateTime dateTime = toDateTime(applyTimeZoneOffset: applyTimeZoneOffset);
    String result = "";
    String dayStr =
        dateTime.day < 10 ? ("0${dateTime.day}") : dateTime.day.toString();
    String monthStr = dateTime.month < 10
        ? ("0${dateTime.month}")
        : dateTime.month.toString();
    result = "$dayStr/$monthStr/${dateTime.year}";
    return result;
  }

  String getTimeAsString({bool applyTimeZoneOffset = true}) {
    DateTime dateTime = toDateTime(applyTimeZoneOffset: applyTimeZoneOffset);
    String result = "";
    String suffix = "AM";
    int hour = dateTime.hour;
    int minute = dateTime.minute;
    if (hour >= 12) {
      suffix = "PM";
      hour = hour % 12;
    }
    if (hour == 0 && suffix == "PM") hour = 12;
    String hourStr = hour < 10 ? ("0$hour") : hour.toString();
    String minuteStr = minute < 10 ? ("0$minute") : minute.toString();
    result += "$hourStr:$minuteStr $suffix";
    return result;
  }

  static TmiDateTime now() {
    return TmiDateTime(DateTime.now().millisecondsSinceEpoch -
        DateTime.now().timeZoneOffset.inMilliseconds);
  }
}
