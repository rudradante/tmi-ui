import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:tmiui/config/config_provider.dart';
import 'package:tmiui/custom_widgets/custom_text.dart';
import 'package:tmiui/extensions/color.dart';
import 'package:tmiui/models.dart/plan.dart';
import 'package:tmiui/screens/add_plan.dart';
import 'package:tmiui/screens/plan_dashboard.dart';
import 'package:tmiui/screens/screen_types.dart';

import '../custom_widgets/bottom_appbar.dart';
import '../custom_widgets/custom_row.dart';
import '../custom_widgets/custom_scaffold.dart';
import '../custom_widgets/should_proceed_dialog.dart';
import '../models.dart/tmi_datetime.dart';

class SchedulePlans extends StatefulWidget {
  const SchedulePlans({Key? key}) : super(key: key);

  @override
  State<SchedulePlans> createState() => _SchedulePlansState();
}

class _SchedulePlansState extends State<SchedulePlans> {
  List<Plan> _plans = [];
  int cardColorIndex = 0;
  final Map<String, Color> _planColors = {};
  final List<Color> _cardColors = [
    HexColor.fromHex(ConfigProvider.getThemeConfig().primaryScheduleCardColor),
    HexColor.fromHex(
        ConfigProvider.getThemeConfig().secondaryScheduleCardColor),
  ];
  TmiDateTime selectedDate = TmiDateTime.nowWithMinDate();
  var selectedView = CalendarView.day;
  var allowedViews = [CalendarView.day, CalendarView.week, CalendarView.month];
  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetchPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: "Schedule",
      appBarTitleSize: 32,
      appBarBackgroundColor: HexColor.fromHex(
          ConfigProvider.getThemeConfig().scaffoldBackgroundColor),
      scaffoldBackgroundColor: Colors.white,
      centerWidget: Container(
          color: Colors.white,
          height: CustomScaffold.bodyHeight,
          child: SfCalendar(
            initialSelectedDate: selectedDate.toDateTime(),
            initialDisplayDate: selectedDate.toDateTime(),
            showNavigationArrow: true,
            showTodayButton: true,
            key: UniqueKey(),
            allowViewNavigation: true,
            allowDragAndDrop: false,
            view: selectedView,
            dataSource: MeetingDataSource(_plans),
            showCurrentTimeIndicator: true,
            appointmentBuilder: appointmentBuilder,
            timeSlotViewSettings:
                const TimeSlotViewSettings(timeIntervalHeight: 60),
            headerHeight: 0,
            headerStyle: CalendarHeaderStyle(
                backgroundColor: HexColor.fromHex(
                    ConfigProvider.getThemeConfig().scaffoldBackgroundColor)),
          )),
      bottomAppBar: getTmiBottomAppBar(context, ScreenType.Schedule),
      actions: [
        MyPlanDateSelector(
          key: UniqueKey(),
          (date) => setState(() {
            selectedDate = date;
          }),
          selectedDate,
          weekView: selectedView == CalendarView.week,
        )
      ],
      floatingActionButton: FloatingActionButton(
        tooltip: "Change view",
        shape: const CircleBorder(),
        backgroundColor: HexColor.fromHex(
            ConfigProvider.getThemeConfig().primaryThemeForegroundColor),
        onPressed: () {},
        child: PopupMenuButton<String>(
            tooltip: "Change view",
            icon: Icon(Icons.calendar_view_day, color: Colors.white),
            onSelected: viewOptionSelected,
            itemBuilder: (context) => ["Day", "Week"]
                .map((e) => PopupMenuItem<String>(
                      value: e,
                      child: CustomText(text: e),
                    ))
                .toList()),
      ),
      // bottomAppBar: BottomAppBar(
      //   padding: const EdgeInsets.symmetric(horizontal: 10),
      //   height: 60,
      //   color: Colors.white,
      //   shape: const CircularNotchedRectangle(),
      //   notchMargin: 5,
      //   child: Row(
      //     mainAxisSize: MainAxisSize.max,
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: <Widget>[
      //       TextButton.icon(
      //           style: ButtonStyle(
      //               backgroundColor: MaterialStateProperty.all(Colors.white)),
      //           onPressed: () => setState(() {
      //                 selectedView = CalendarView.day;
      //               }),
      //           icon: const Icon(
      //             Icons.schedule,
      //             color: Colors.black,
      //           ),
      //           label: const CustomText(text: "Day View")),
      //       TextButton.icon(
      //           style: ButtonStyle(
      //               backgroundColor: MaterialStateProperty.all(Colors.white)),
      //           onPressed: () => setState(() {
      //                 selectedView = CalendarView.week;
      //               }),
      //           icon: const Icon(
      //             Icons.schedule,
      //             color: Colors.black,
      //           ),
      //           label: const CustomText(text: "Week View"))
      //     ],
      //   ),
      // ),
    );
  }

  void viewOptionSelected(String option) {
    if (option == "Day") {
      selectedView = CalendarView.day;
    }
    if (option == "Week") {
      selectedView = CalendarView.week;
    }
    setState(() {});
  }

  Widget appointmentBuilder(BuildContext context,
      CalendarAppointmentDetails calendarAppointmentDetails) {
    final Plan appointment = calendarAppointmentDetails.appointments.first;
    var color = _planColors.containsKey(appointment.planId)
        ? _planColors[appointment.planId]
        : appointment.endTime.getMillisecondsSinceEpoch() <
                TmiDateTime.now().getMillisecondsSinceEpoch()
            ? HexColor.fromHex(
                ConfigProvider.getThemeConfig().pastScheduleCardColor)
            : _cardColors[(cardColorIndex++) % _cardColors.length];
    _planColors.putIfAbsent(appointment.planId, () => color!);
    return Container(
      margin: EdgeInsets.zero,
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.all(4),
      width: calendarAppointmentDetails.bounds.width,
      height: calendarAppointmentDetails.bounds.height,
      child: Tooltip(
        message: appointment.title,
        child: InkWell(
          onDoubleTap: () => planDoubleTapped(appointment),
          child: CustomRow(
            children: [
              Expanded(
                child: CustomText(
                  align: TextAlign.left,
                  text: appointment.title,
                  color: Colors.white,
                ),
              ),
              PopupMenuButton<String>(
                  icon: Icon(Icons.adaptive.more, color: Colors.white),
                  onSelected: (val) => optionSelected(val, appointment),
                  itemBuilder: (context) =>
                      ((TmiDateTime.now().getMillisecondsSinceEpoch() -
                                      appointment.endTime
                                          .getMillisecondsSinceEpoch()) >=
                                  0
                              ? ["Clone", "Remove"]
                              : ["Clone", "Reschedule", "Remove"])
                          .map((e) => PopupMenuItem<String>(
                                value: e,
                                child: CustomText(text: e),
                              ))
                          .toList()),
            ],
          ),
        ),
      ),
    );
  }

  void fetchPlans() async {
    _plans = await Plan.getAllPlans(null, context);
    setState(() {});
  }

  void planDoubleTapped(Plan plan) async {
    AddOrUpdatePlanRoute.push(context, plan, (p0) {
      fetchPlans();
    }, notEditable: true, title: "Plan Details", forceDialog: true);
  }

  optionSelected(String val, Plan plan) {
    if (val == "Clone") {
      cloneTapped(plan);
    } else if (val == "Reschedule") {
      rescheduleTapped(plan);
    } else if (val == "Remove") {
      removePlanTapped(plan);
    }
  }

  void rescheduleTapped(Plan plan) {
    AddOrUpdatePlanRoute.push(context, plan, (p0) {
      setState(() {
        fetchPlans();
      });
    }, onlyTimeEditable: true, title: "Reschedule Plan", forceDialog: true);
  }

  void removePlanTapped(Plan plan) async {
    var proceed = await showShouldProceedDialog(
        "Delete", "Are you sure you want to remove this plan?", context);
    if (!proceed) return;
    var result = await Plan.deletePlan(plan.planId, context);
    if (result) {
      _plans.removeWhere((element) => element.planId == plan.planId);
      setState(() {});
    }
  }

  void cloneTapped(Plan plan) async {
    plan.planId = TmiDateTime.now().getMillisecondsSinceEpoch().toString();
    await PlanDashboardRoute.push(context,
        selectedPlan: plan,
        isCloneView: true,
        editPlanSectionTitle: "Clone Plan",
        planListSectionTitle: "Cloned Plans");
    fetchPlans();
  }
}

/// An object to set the appointment collection data source to calendar, which
/// used to map the custom appointment data to the calendar appointment, and
/// allows to add, remove or reset the appointment collection.
class MeetingDataSource extends CalendarDataSource {
  /// Creates a meeting data source, which used to set the appointment
  /// collection to the calendar
  MeetingDataSource(List<Plan> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    var date = _getMeetingData(index).startTime.toDateTime();
    return DateTime(date.year, date.month, date.day, date.hour, date.minute);
  }

  @override
  DateTime getEndTime(int index) {
    var date = _getMeetingData(index).endTime.toDateTime();
    return DateTime(date.year, date.month, date.day, date.hour, date.minute);
  }

  @override
  String getSubject(int index) {
    return _getMeetingData(index).title;
  }

  @override
  Color getColor(int index) {
    return HexColor.fromHex(
        ConfigProvider.getThemeConfig().primaryThemeForegroundColor);
  }

  @override
  bool isAllDay(int index) {
    return false;
  }

  Plan _getMeetingData(int index) {
    final dynamic meeting = appointments![index];
    late final Plan meetingData;
    if (meeting is Plan) {
      meetingData = meeting;
    }

    return meetingData;
  }
}

class SchedulePlansRoute {
  static Future push(BuildContext context, List<Plan> plans,
      void Function(Plan) onPlanUpdated) async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const SchedulePlans()));
  }
}
