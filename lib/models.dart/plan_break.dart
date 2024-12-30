import 'package:flutter/foundation.dart';
import 'package:tmiui/models.dart/plan.dart';
import 'package:tmiui/models.dart/tmi_datetime.dart';

int _idCounter = DateTime.now().millisecondsSinceEpoch;

class PlanBreak {
  String id = "";
  final TmiDateTime startTime, endTime;

  PlanBreak(this.startTime, this.endTime) {
    id = (_idCounter++).toString();
    print(id);
  }

  static PlanBreak fromJson(Map<String, dynamic> json) {
    return PlanBreak(
        TmiDateTime(json['startTime']), TmiDateTime(json['endTime']));
  }

  static String? validateBreakTimingsWithPlan(Plan plan, PlanBreak planBreak) {
    var breakStartTime = planBreak.startTime.getMillisecondsSinceEpoch();
    var breakEndTime = planBreak.endTime.getMillisecondsSinceEpoch();
    var planStartTime = plan.startTime.getMillisecondsSinceEpoch();
    var planEndTime = plan.endTime.getMillisecondsSinceEpoch();
    if (breakStartTime >= breakEndTime) {
      return "Break interval must be a least a minute long";
    }
    if (breakStartTime <= planStartTime ||
        breakStartTime >= planEndTime ||
        breakEndTime <= planStartTime ||
        breakEndTime >= planEndTime) {
      return "Break intervals must be within plan duration";
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.getMillisecondsSinceEpoch(),
      'endTime': endTime.getMillisecondsSinceEpoch()
    };
  }
}
