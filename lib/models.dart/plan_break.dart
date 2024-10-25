import 'package:flutter/foundation.dart';
import 'package:tmiui/models.dart/plan.dart';
import 'package:tmiui/models.dart/tmi_datetime.dart';

class PlanBreak {
  String id = "";
  final TmiDateTime startTime, endTime;

  PlanBreak(this.startTime, this.endTime) {
    id = UniqueKey().toString();
  }

  static PlanBreak fromJson(Map<String, dynamic> json) {
    return PlanBreak(
        TmiDateTime(json['startTime']), TmiDateTime(json['endTime']));
  }

  static String? validateBreakTimingsWithPlan(Plan plan, PlanBreak planBreak) {
    if (planBreak.startTime.getMillisecondsSinceEpoch() <
        plan.startTime.getMillisecondsSinceEpoch()) {
      return "Break start time cannot be less than plan start time";
    }
    if (planBreak.endTime.getMillisecondsSinceEpoch() >
        plan.endTime.getMillisecondsSinceEpoch()) {
      return "Break end time cannot be ahead of plan end time";
    }
    if (planBreak.startTime.getMillisecondsSinceEpoch() >
        planBreak.endTime.getMillisecondsSinceEpoch()) {
      return "Break start time cannot me ahead of end time";
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
