import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tmiui/models.dart/base_table.dart';
import 'package:tmiui/models.dart/login_user.dart';
import 'package:tmiui/models.dart/plan_break.dart';
import 'package:tmiui/models.dart/plan_note.dart';
import 'package:tmiui/models.dart/plan_references.dart';
import 'package:tmiui/models.dart/plan_review.dart';
import 'package:tmiui/models.dart/reminder.dart';
import 'package:tmiui/models.dart/tmi_datetime.dart';

import '../server/request.dart';

class Plan extends BaseTable {
  String planId, userId, title, description;
  TmiDateTime startTime, endTime;
  List<PlanReference> planReferences;
  List<PlanBreak> breaks;
  List<PlanNote> planNotes;
  PlanReview? review;

  Plan(
      TmiDateTime createdOn,
      TmiDateTime updatedOn,
      String createdBy,
      String updatedBy,
      this.title,
      this.description,
      this.startTime,
      this.endTime,
      this.planId,
      this.userId,
      this.planReferences,
      this.breaks,
      this.planNotes,
      this.review)
      : super(createdBy, updatedBy, createdOn, updatedOn) {
    breaks.sort((a, b) => a.startTime
        .getMillisecondsSinceEpoch()
        .compareTo(b.startTime.getMillisecondsSinceEpoch()));
    planNotes.sort((a, b) => b.createdOn
        .getMillisecondsSinceEpoch()
        .compareTo(a.createdOn.getMillisecondsSinceEpoch()));
  }

  static Plan fromJson(Map<String, dynamic> json) {
    try {
      return Plan(
          TmiDateTime(json['createdOn'] ?? 0),
          TmiDateTime(json['updatedOn'] ?? 0),
          json['createdBy'] ?? "",
          json['updatedBy'] ?? "",
          json['title'] ?? "",
          json['description'] ?? "",
          TmiDateTime(json['startTime'] ?? 0),
          TmiDateTime(json['endTime'] ?? 0),
          json['planId'] ?? "",
          json['userId'] ?? "",
          ((json['planReferences'] as List<dynamic>?) ?? [])
              .map((e) => PlanReference.fromJson((e as Map<String, dynamic>)))
              .toList(),
          ((json['breaks'] as List<dynamic>?) ?? [])
              .map((e) => PlanBreak.fromJson((e as Map<String, dynamic>)))
              .toList(),
          ((json['notes'] as List<dynamic>?) ?? [])
              .map((e) => PlanNote.fromJson(
                  (e as Map<String, dynamic>), json['planId'] ?? ""))
              .toList(),
          (json['review'] == null
              ? null
              : PlanReview.fromJson(json['review'], json['planId'])));
    } catch (err) {
      print(err);
      print(json);
      return Plan.newPlan();
    }
  }

  static Plan newPlan() {
    return Plan(
        TmiDateTime(DateTime.now().millisecondsSinceEpoch + 3600000),
        TmiDateTime(DateTime.now().millisecondsSinceEpoch + 7200000),
        LoginUser.currentLoginUser.userId,
        LoginUser.currentLoginUser.userId,
        "",
        "",
        TmiDateTime(
            TmiDateTime.now().getMillisecondsSinceEpoch() + 3600 * 1000),
        TmiDateTime(
            TmiDateTime.now().getMillisecondsSinceEpoch() + 7200 * 1000),
        TmiDateTime.now().getMillisecondsSinceEpoch().toString(),
        LoginUser.currentLoginUser.userId,
        [],
        [],
        [],
        null);
  }

  Map<String, dynamic> toJson() {
    breaks.sort((a, b) => a.startTime
        .getMillisecondsSinceEpoch()
        .compareTo(b.startTime.getMillisecondsSinceEpoch()));
    return <String, dynamic>{
      'title': title,
      'description': description,
      'startTime': startTime.getMillisecondsSinceEpoch(),
      'endTime': endTime.getMillisecondsSinceEpoch(),
      'planId': planId,
      'userId': userId,
      'planReferences': planReferences,
      'breaks': breaks
    };
  }

  static Future<Plan?> createPlan(Plan plan, BuildContext context) async {
    var response = await Server.post('/plan', {}, jsonEncode(plan), context);
    if (Server.isSuccessHttpCode(response.statusCode)) {
      await Reminder.syncReminders(context);
      return plan = Plan.fromJson((jsonDecode(response.body) as List)[0]);
    }
    return null;
  }

  static Future<Plan?> updatePlan(Plan plan, BuildContext context) async {
    var response = await Server.update('/plan', {}, jsonEncode(plan), context);
    if (Server.isSuccessHttpCode(response.statusCode)) {
      await Reminder.syncReminders(context);
      return plan;
    }
    return null;
  }

  static Future<List<Plan>> getAllPlans(
      TmiDateTime? dateTime, BuildContext context) async {
    var url = '/plan';
    if (dateTime != null) {
      url += '/date/${dateTime.getMillisecondsSinceEpoch()}';
    }
    var response = await Server.get(url, {}, context);
    if (Server.isSuccessHttpCode(response.statusCode)) {
      var responseJson = jsonDecode(response.body);
      var results =
          (responseJson as List<dynamic>).map((e) => Plan.fromJson(e)).toList();
      results.sort((a, b) => a.startTime
          .getMillisecondsSinceEpoch()
          .compareTo(b.endTime.getMillisecondsSinceEpoch()));
      return results;
    }
    return [];
  }

  static Future<List<Plan>> getPredictedPlans(
      TmiDateTime dateTime, BuildContext context) async {
    var url = '/plan/predict';
    url += '/${dateTime.getMillisecondsSinceEpoch()}';
    var response = await Server.get(url, {}, context);
    if (Server.isSuccessHttpCode(response.statusCode)) {
      var responseJson = jsonDecode(response.body);
      print(responseJson);
      print(response.statusCode);
      var results =
          (responseJson as List<dynamic>).map((e) => Plan.fromJson(e)).toList();
      results.sort((a, b) => a.startTime
          .getMillisecondsSinceEpoch()
          .compareTo(b.endTime.getMillisecondsSinceEpoch()));
      return results;
    }
    return [];
  }

  static Future<bool> deletePlan(String planId, BuildContext context) async {
    var response = await Server.delete('/plan/$planId', {}, context);
    var deleted = Server.isSuccessHttpCode(response.statusCode);
    if (deleted) {
      await Reminder.syncReminders(context);
    }
    return deleted;
  }

  bool isNewPlan() => int.tryParse(planId) != null;
}
