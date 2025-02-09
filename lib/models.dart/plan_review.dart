import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tmiui/models.dart/tmi_datetime.dart';

import '../server/request.dart';

class PlanReview {
  int percentage;
  TmiDateTime createdOn;
  String planId;
  String reviewId;
  int updatedCount;

  PlanReview(this.reviewId, this.planId, this.createdOn, this.percentage,
      this.updatedCount);

  static PlanReview fromJson(Map<String, dynamic> json, String planId) {
    return PlanReview(
        json['reviewId'],
        planId,
        TmiDateTime(
            json['createdOn'] ?? TmiDateTime.now().getMillisecondsSinceEpoch()),
        json['percentage'] ?? 0,
        json['updatedCount'] ?? 1);
  }

  static PlanReview newReview(String planId) {
    return PlanReview(TmiDateTime.now().getMillisecondsSinceEpoch().toString(),
        planId, TmiDateTime.now(), 0, 0);
  }

  Map<String, dynamic> toJson() {
    return {"percentage": percentage, "planId": planId, 'reviewId': reviewId};
  }

  static Future<PlanReview?> updateReview(
      PlanReview planReview, BuildContext context) async {
    var response = await Server.update(
        '/plan/review', {}, jsonEncode(planReview), context);
    if (Server.isSuccessHttpCode(response.statusCode)) {
      print(response.body);
      return PlanReview.fromJson(jsonDecode(response.body), planReview.planId);
    }
    return null;
  }
}
