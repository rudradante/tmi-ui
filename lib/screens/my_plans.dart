import 'package:flutter/material.dart';
import 'package:tmiui/config/config_provider.dart';
import 'package:tmiui/config/theme.dart';
import 'package:tmiui/custom_widgets/custom_list_view.dart';
import 'package:tmiui/screens/my_plan_card.dart';

import '../models.dart/plan.dart';

class MyPlans extends StatefulWidget {
  final List<Plan> _plans;
  final Function(Plan) onPlanSelected;
  final Function(String) onPlanDeleted;
  final String? selectedPlanId;
  const MyPlans(
      this._plans, this.onPlanSelected, this.onPlanDeleted, this.selectedPlanId,
      {Key? key})
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
              widget._plans[i].planId == widget.selectedPlanId);
        },
        itemCount: widget._plans.length);
  }
}