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

import '../custom_widgets/custom_text.dart';
import '../models.dart/plan.dart';
import '../models.dart/tmi_datetime.dart';
import 'my_plans.dart';

class PlanDashboard extends StatefulWidget {
  final Plan? selectedPlan;
  const PlanDashboard(this.selectedPlan, {Key? key}) : super(key: key);

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
      refreshPlans(preserveSelectedPlan: widget.selectedPlan != null);
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = ConfigProvider.getThemeConfig();
    var sf = calculateScreenFactors(context);
    return CustomScaffold(
      showBackButton: false,
      title: sf.maxComponents <= 2 ? "My Plans" : "Let's add a plan",
      appBarTitleSize: 32,
      floatingActionButton: FloatingActionButton(
        tooltip: "Add new plan",
        shape: const CircleBorder(),
        onPressed: addNewPlanTapped,
        elevation: 8,
        backgroundColor: HexColor.fromHex(theme.primaryThemeForegroundColor),
        foregroundColor: Colors.white,
        child: Icon(Icons.add, size: 32 * sf.cf),
      ),
      scaffoldBackgroundColor: HexColor.fromHex(theme.scaffoldBackgroundColor),
      actions: [
        if (sf.maxComponents > 2)
          SizedBox(
            width: 2 / 3 * sf.size.width - 32,
            child: CustomText(
                text: "My Plans",
                textStyle: GoogleFonts.seaweedScript(
                    textStyle: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 32,
                        color: HexColor.fromHex(theme.appBarForegroundColor)))),
          ),
        MyPlanDateSelector(key: UniqueKey(), selectedDateChanged, selectedDate)
      ],
      centerWidget: sf.maxComponents <= 2
          ? SizedBox.fromSize(
              size: sf.size,
              child: MyPlans(
                  _plans, planSelected, planDeleted, selectedPlan.planId))
          : CustomRow(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    flex: 1,
                    child: AddOrUpdatePlan(
                      selectedPlan,
                      newPlanAdded,
                      key: selectedPlanKey,
                    )),
                Expanded(
                  flex: 2,
                  child: MyPlans(
                      _plans, planSelected, planDeleted, selectedPlan.planId,
                      key: selectedPlanKey),
                )
              ],
            ),
      bottomAppBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 60,
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 5,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TextButton.icon(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white)),
                onPressed: scheduleTapped,
                icon: const Icon(
                  Icons.schedule,
                  color: Colors.black,
                ),
                label: const CustomText(text: "Schedule")),
            TextButton.icon(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white)),
                onPressed: scheduleTapped,
                icon: const Icon(
                  Icons.account_box,
                  color: Colors.black,
                ),
                label: const CustomText(text: "My Account"))
          ],
        ),
      ),
    );
  }

  void addNewPlanTapped() {
    ScreenFactors sf = calculateScreenFactors(context);
    if (sf.maxComponents <= 2) {
      AddOrUpdatePlanRoute.push(context, Plan.newPlan(), newPlanAdded);
    } else {
      setState(() {
        selectedPlan = Plan.newPlan();
        selectedPlanKey = Key(DateTime.now().microsecondsSinceEpoch.toString());
      });
    }
  }

  void newPlanAdded(Plan plan) {
    refreshPlans();
  }

  void refreshPlans({bool preserveSelectedPlan = false}) async {
    _plans = await Plan.getAllPlans(selectedDate, context);
    selectedPlanKey = Key(DateTime.now().microsecondsSinceEpoch.toString());
    selectedPlan = Plan.newPlan();
    if (preserveSelectedPlan) {
      planSelected(widget.selectedPlan!);
    } else {
      setState(() {});
    }
  }

  planSelected(Plan selectedPlan) {
    ScreenFactors sf = calculateScreenFactors(context);
    if (sf.maxComponents <= 2) {
      AddOrUpdatePlanRoute.push(context, selectedPlan, newPlanAdded);
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
  final void Function(TmiDateTime) onDateChanged;
  final TmiDateTime selectedDate;
  const MyPlanDateSelector(this.onDateChanged, this.selectedDate, {Key? key})
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
            text: selectedDate.getDateAsString(),
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
    selectedDate = TmiDateTime(
        selectedDate.getMillisecondsSinceEpoch() - 24 * 3600 * 1000);
    widget.onDateChanged(selectedDate);
  }

  void nextDateTapped() {
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
  static void push(BuildContext context, {Plan? selectedPlan}) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => PlanDashboard(selectedPlan)),
        (route) => false);
  }
}
