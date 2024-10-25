import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tmiui/models.dart/tmi_datetime.dart';

import '../server/request.dart';

class PlanNote {
  String note;
  TmiDateTime createdOn;
  String planId;
  String planNoteId;

  PlanNote(this.note, this.createdOn, this.planId, this.planNoteId);

  static PlanNote fromJson(Map<String, dynamic> json, String planId) {
    return PlanNote(
        json['note'], TmiDateTime(json['createdOn']), planId, json['noteId']);
  }

  Map<String, dynamic> toJson() {
    return {
      "notes": note,
      "dateTime": createdOn.getMillisecondsSinceEpoch(),
      "planId": planId,
      'planNoteId': planNoteId
    };
  }

  static Future<PlanNote?> addPlanNote(
      PlanNote planNote, BuildContext context) async {
    print(jsonEncode(planNote));
    var response =
        await Server.post('/note', {}, jsonEncode(planNote), context);
    if (Server.isSuccessHttpCode(response.statusCode)) {
      try {
        planNote.planNoteId = jsonDecode(response.body)['noteId'];
        return planNote;
      } catch (err) {
        print(err);
      }
    }
    return null;
  }

  static Future<bool> removePlanNote(
      String planNoteId, BuildContext context) async {
    var response = await Server.delete('/note/$planNoteId', {}, context);
    return Server.isSuccessHttpCode(response.statusCode);
  }
}
