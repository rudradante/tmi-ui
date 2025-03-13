import 'package:flutter/material.dart';
import 'package:tmiui/custom_widgets/custom_list_view.dart';
import 'package:tmiui/screens/my_plan_card.dart';

import '../models.dart/plan.dart';

class MyPlans extends StatefulWidget {
  final List<Plan> _plans;
  final Function(Plan) onPlanSelected;
  final Function(String) onPlanDeleted;
  final String? selectedPlanId;
  final bool readonly;
  const MyPlans(
      this._plans, this.onPlanSelected, this.onPlanDeleted, this.selectedPlanId,
      {Key? key, this.readonly = false})
      : super(key: key);

  @override
  State<MyPlans> createState() => _MyPlansState();
}

class _MyPlansState extends State<MyPlans> {
  @override
  Widget build(BuildContext context) {
    return CustomListView(
        itemBuilder: (context, i) {
          return MyPlanCard(
              widget._plans[i],
              widget.onPlanSelected,
              widget.onPlanDeleted,
              widget._plans[i].planId == widget.selectedPlanId,
              widget.readonly);
        },
        itemCount: widget._plans.length);
  }
}
