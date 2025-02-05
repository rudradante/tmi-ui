import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tmiui/models.dart/tmi_datetime.dart';

import '../server/request.dart';

class PlanReview {
  int percentage;
  TmiDateTime createdOn;
  String planId;
  String reviewId;

  PlanReview(this.reviewId, this.planId, this.createdOn, this.percentage);

  static PlanReview fromJson(Map<String, dynamic> json, String planId) {
    return PlanReview(json['reviewId'], planId, TmiDateTime(json['createdOn']),
        json['percentage']);
  }

  static PlanReview newReview(String planId) {
    return PlanReview(TmiDateTime.now().getMillisecondsSinceEpoch().toString(),
        planId, TmiDateTime.now(), 0);
  }

  Map<String, dynamic> toJson() {
    return {"percentage": percentage, "planId": planId, 'reviewId': reviewId};
  }

  static Future<PlanReview?> updateReview(
      PlanReview planReview, BuildContext context) async {
    var response =
        await Server.update('/review', {}, jsonEncode(planReview), context);
    if (Server.isSuccessHttpCode(response.statusCode)) {
      planReview.reviewId = jsonDecode(response.body)['reviewId'];
      return planReview;
    }
    return null;
  }
}
