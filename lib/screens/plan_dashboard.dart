import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmiui/config/config_provider.dart';
import 'package:tmiui/config/theme.dart';
import 'package:tmiui/custom_widgets/custom_row.dart';
import 'package:tmiui/custom_widgets/custom_scaffold.dart';
import 'package:tmiui/extensions/color.dart';
import 'package:tmiui/helpers/date_time.dart';
import 'package:tmiui/screens/add_plan.dart';
import 'package:tmiui/screens/schedule.dart';
import 'package:tmiui/screens/screen_types.dart';

import '../custom_widgets/bottom_appbar.dart';
import '../custom_widgets/custom_text.dart';
import '../models.dart/plan.dart';
import '../models.dart/tmi_datetime.dart';
import 'my_plans.dart';

class PlanDashboard extends StatefulWidget {
  final Plan? selectedPlan;
  final String editPlanSectionTitle, planListSectionTitle;
  final bool isCloneView;
  const PlanDashboard(this.selectedPlan, this.editPlanSectionTitle,
      this.planListSectionTitle, this.isCloneView,
      {Key? key})
      : super(key: key);

  @override
  State<PlanDashboard> createState() => _PlanDashboardState();
}

class _PlanDashboardState extends State<PlanDashboard> {
  List<Plan> _plans = [];
  Plan selectedPlan = Plan.newPlan();
  TmiDateTime selectedDate = TmiDateTime.nowWithMinDate();
  Key selectedPlanKey = Key(DateTime.now().microsecondsSinceEpoch.toString());

  @override
  void initState() {
    super.initState();
    if (widget.selectedPlan != null) {
      selectedDate = widget.selectedPlan!.startTime.toMinDate();
      selectedPlan = widget.selectedPlan!;
    }
    selectedPlanKey = Key(DateTime.now().microsecondsSinceEpoch.toString());
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!widget.isCloneView) {
        refreshPlans(preserveSelectedPlan: widget.selectedPlan != null);
      } else {
        ScreenFactors sf = calculateScreenFactors(context);
        if (sf.maxComponents <= 2) {
          AddOrUpdatePlanRoute.push(context, selectedPlan, newPlanAdded,
              title: widget.editPlanSectionTitle,
              onlyTimeEditable: widget.isCloneView);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = ConfigProvider.getThemeConfig();
    var sf = calculateScreenFactors(context);
    return CustomScaffold(
        showBackButton: false,
        title: sf.maxComponents <= 2
            ? widget.editPlanSectionTitle
            : widget.editPlanSectionTitle,
        appBarTitleSize: 32,
        floatingActionButton: widget.isCloneView && sf.maxComponents > 2
            ? null
            : FloatingActionButton(
                tooltip: widget.isCloneView
                    ? "Clone plan"
                    : sf.maxComponents > 2
                        ? "Refresh window"
                        : "Add new plan",
                shape: const CircleBorder(
                    side: BorderSide(width: 2, color: Colors.white)),
                onPressed: addNewPlanTapped,
                elevation: 8,
                backgroundColor:
                    HexColor.fromHex(theme.primaryThemeForegroundColor),
                foregroundColor: Colors.white,
                child: Icon(
                    widget.isCloneView
                        ? Icons.copy
                        : sf.maxComponents > 2
                            ? Icons.refresh
                            : Icons.add,
                    size: 32 * sf.cf),
              ),
        scaffoldBackgroundColor:
            HexColor.fromHex(theme.scaffoldBackgroundColor),
        actions: [
          // if (sf.maxComponents > 2)
          //   SizedBox(
          //     width: sf.size.width / 2,
          //     child: CustomText(
          //         text: widget.planListSectionTitle,
          //         textStyle: GoogleFonts.seaweedScript(
          //             textStyle: TextStyle(
          //                 fontWeight: FontWeight.normal,
          //                 fontSize: 32,
          //                 color:
          //                     HexColor.fromHex(theme.appBarForegroundColor)))),
          //   ),
          widget.isCloneView
              ? const SizedBox()
              : MyPlanDateSelector(
                  key: UniqueKey(), selectedDateChanged, selectedDate)
        ],
        centerWidget: sf.maxComponents <= 2
            ? SizedBox.fromSize(
                size: sf.size,
                child: MyPlans(
                  _plans,
                  planSelected,
                  planDeleted,
                  selectedPlan.planId,
                  readonly: widget.isCloneView,
                ))
            : CustomRow(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      flex: 1,
                      child: AddOrUpdatePlan(
                        selectedPlan,
                        newPlanAdded,
                        key: selectedPlanKey,
                        notEditable: !widget.isCloneView &&
                            selectedPlan.startTime
                                    .getMillisecondsSinceEpoch() <=
                                TmiDateTime.now().getMillisecondsSinceEpoch(),
                        onlyTimeEditable: widget.isCloneView,
                      )),
                  Expanded(
                    flex: 2,
                    child: MyPlans(
                      _plans,
                      planSelected,
                      planDeleted,
                      selectedPlan.planId,
                      key: selectedPlanKey,
                      readonly: widget.isCloneView,
                    ),
                  )
                ],
              ),
        bottomAppBar: widget.isCloneView
            ? null
            : getTmiBottomAppBar(context, ScreenType.Dashboard));
  }

  void addNewPlanTapped() {
    ScreenFactors sf = calculateScreenFactors(context);
    Plan plan = widget.isCloneView ? widget.selectedPlan! : Plan.newPlan();
    if (sf.maxComponents <= 2) {
      AddOrUpdatePlanRoute.push(context, plan, newPlanAdded,
          title: widget.editPlanSectionTitle,
          onlyTimeEditable: widget.isCloneView,
          notEditable: !widget.isCloneView &&
              plan.startTime.getMillisecondsSinceEpoch() <=
                  TmiDateTime.now().getMillisecondsSinceEpoch());
    } else {
      setState(() {
        selectedPlan = Plan.newPlan();
        selectedPlanKey = Key(DateTime.now().microsecondsSinceEpoch.toString());
      });
    }
  }

  void newPlanAdded(Plan plan) {
    var sf = calculateScreenFactors(context);
    if (sf.maxComponents <= 2 && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    if (widget.isCloneView) {
      _plans.add(plan);
      setState(() {});
    } else {
      refreshPlans();
    }
  }

  void refreshPlans({bool preserveSelectedPlan = false}) async {
    _plans = await Plan.getAllPlans(selectedDate, context);
    _plans.sort((a, b) => a.createdOn
        .getMillisecondsSinceEpoch()
        .compareTo(b.createdOn.getMillisecondsSinceEpoch()));
    selectedPlanKey = Key(DateTime.now().microsecondsSinceEpoch.toString());
    selectedPlan = Plan.newPlan();
    if (preserveSelectedPlan) {
      planSelected(widget.selectedPlan!);
    } else {
      setState(() {});
    }
  }

  planSelected(Plan selectedPlan) {
    if (widget.isCloneView) {
      PlanDashboardRoute.push(context,
          isCloneView: false, selectedPlan: selectedPlan);
      return;
    }
    ScreenFactors sf = calculateScreenFactors(context);
    if (sf.maxComponents <= 2) {
      AddOrUpdatePlanRoute.push(context, selectedPlan, newPlanAdded,
          onlyTimeEditable: widget.isCloneView,
          notEditable: !widget.isCloneView &&
              selectedPlan.startTime.getMillisecondsSinceEpoch() <=
                  TmiDateTime.now().getMillisecondsSinceEpoch());
    } else {
      setState(() {
        this.selectedPlan = selectedPlan;
        selectedPlanKey = Key(DateTime.now().microsecondsSinceEpoch.toString());
      });
    }
  }

  void selectedDateChanged(TmiDateTime selectedDate) {
    this.selectedDate = selectedDate;
    refreshPlans();
  }

  planDeleted(String p1) {
    refreshPlans();
  }

  void scheduleTapped() async {
    await SchedulePlansRoute.push(context, [], (p0) {});
    refreshPlans();
  }
}

class MyPlanDateSelector extends StatefulWidget {
  final bool weekView;
  final void Function(TmiDateTime) onDateChanged;
  final TmiDateTime selectedDate;
  const MyPlanDateSelector(this.onDateChanged, this.selectedDate,
      {Key? key, this.weekView = false})
      : super(key: key);

  @override
  State<MyPlanDateSelector> createState() => _MyPlanDateSelectorState();
}

class _MyPlanDateSelectorState extends State<MyPlanDateSelector> {
  TmiDateTime selectedDate = TmiDateTime.nowWithMinDate();

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    var theme = ConfigProvider.getThemeConfig();
    var dateText = selectedDate.getDateAsString();
    if (widget.weekView) {
      var weekDates = TmiDateTime.getStartAndEndOfWeek(selectedDate);
      dateText =
          "${weekDates[0].getDateAsString()} - ${weekDates[1].getDateAsString()}";
    }
    return CustomRow(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
            onPressed: previousDateTapped,
            icon: Icon(Icons.arrow_back_ios_outlined,
                color: HexColor.fromHex(theme.appBarForegroundColor))),
        InkWell(
          onTap: chooseDateTapped,
          child: CustomText(
            text: dateText,
            bold: true,
            color: HexColor.fromHex(theme.appBarForegroundColor),
          ),
        ),
        IconButton(
            onPressed: nextDateTapped,
            icon: Icon(Icons.arrow_forward_ios_outlined,
                color: HexColor.fromHex(theme.appBarForegroundColor))),
      ],
    );
  }

  void previousDateTapped() {
    if (widget.weekView) {
      var weekDates = TmiDateTime.getStartAndEndOfWeek(selectedDate);
      selectedDate = weekDates[0];
    }
    selectedDate = TmiDateTime(
        selectedDate.getMillisecondsSinceEpoch() - 24 * 3600 * 1000);
    widget.onDateChanged(selectedDate);
  }

  void nextDateTapped() {
    if (widget.weekView) {
      var weekDates = TmiDateTime.getStartAndEndOfWeek(selectedDate);
      selectedDate = weekDates[1];
    }
    selectedDate = TmiDateTime(
        selectedDate.getMillisecondsSinceEpoch() + 24 * 3600 * 1000);
    widget.onDateChanged(selectedDate);
  }

  void chooseDateTapped() async {
    var selected = await chooseDate(
        context,
        selectedDate,
        selectedDate.subtract(const Duration(days: 365)),
        selectedDate.add(const Duration(days: 365)));
    if (selected == null) return;
    widget.onDateChanged(selected);
  }
}

class PlanDashboardRoute {
  static Future push(BuildContext context,
      {Plan? selectedPlan,
      String editPlanSectionTitle = "My Plans",
      String planListSectionTitle = "",
      bool isCloneView = false}) async {
    if (!isCloneView) {
      await Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => PlanDashboard(selectedPlan,
                  editPlanSectionTitle, planListSectionTitle, isCloneView)),
          (route) => false);
    } else {
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PlanDashboard(
                    selectedPlan,
                    editPlanSectionTitle,
                    planListSectionTitle,
                    isCloneView,
                  )));
    }
  }
}
