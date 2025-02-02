// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import '../models.dart/tmi_datetime.dart';

Future<TmiDateTime?> chooseDateAndTime(BuildContext context,
    {String? fieldLableText,
    TmiDateTime? initialDateTime,
    TmiDateTime? firstDateTime,
    TmiDateTime? lastDateTime}) async {
  initialDateTime = initialDateTime ?? TmiDateTime.now();
  firstDateTime = firstDateTime ?? TmiDateTime.now();
  lastDateTime = lastDateTime ??
      TmiDateTime(TmiDateTime.now().getMillisecondsSinceEpoch() +
          100 * 365 * 24 * 3600 * 1000);

  var date = await chooseDate(
      context, initialDateTime, firstDateTime, lastDateTime,
      fieldLableText: fieldLableText);
  if (date == null) return null;
  var time = await chooseTime(context, date, fieldLabelText: fieldLableText);
  if (time == null) return null;
  return time;
}

Future<TmiDateTime?> chooseDate(
  BuildContext context,
  TmiDateTime initialDateTime,
  TmiDateTime firstDateTime,
  TmiDateTime lastDateTime, {
  String? fieldLableText,
}) async {
  var date = await showDatePicker(
      fieldLabelText: "(DD/MM/YYYY)",
      context: context,
      fieldHintText: fieldLableText,
      helpText: fieldLableText,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      //barrierLabel: fieldLableText,
      initialDate: initialDateTime.toDateTime(),
      firstDate: firstDateTime.toDateTime(),
      lastDate: lastDateTime.toDateTime());
  if (date == null) return null;
  var dateTime = DateTime(date.year, date.month, date.day);
  return TmiDateTime(dateTime.millisecondsSinceEpoch);
}

Future<TmiDateTime?> chooseTime(BuildContext context, TmiDateTime preFixedDate,
    {String? fieldLabelText}) async {
  var timeOfDay = await showTimePicker(
      context: context,
      initialTime: preFixedDate.toTimeOfDay(),
      helpText: fieldLabelText);
  if (timeOfDay == null) {
    return null;
  }
  var date = DateTime(
      preFixedDate.toDateTime().year,
      preFixedDate.toDateTime().month,
      preFixedDate.toDateTime().day,
      timeOfDay.hour,
      timeOfDay.minute);
  return TmiDateTime(date.millisecondsSinceEpoch);
}
