// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import '../models.dart/tmi_datetime.dart';

Future<TmiDateTime?> chooseDateAndTime(BuildContext context,
    {String? fieldLableText}) async {
  var date = await showDatePicker(
      fieldLabelText: fieldLableText,
      context: context,
      initialDate: TmiDateTime.now().toDateTime(),
      firstDate: TmiDateTime.now().toDateTime(),
      lastDate: DateTime(DateTime.now().year + 1));
  if (date == null) return null;
  var time = await showTimePicker(
      context: context, initialTime: TimeOfDay.now(), helpText: fieldLableText);
  if (time == null) return null;
  DateTime result =
      DateTime(date.year, date.month, date.day, time.hour, time.minute);
  return TmiDateTime(
      result.millisecondsSinceEpoch - result.timeZoneOffset.inMilliseconds);
}
