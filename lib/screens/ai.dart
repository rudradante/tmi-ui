import 'dart:async';

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

class AIPlans extends StatefulWidget {
  const AIPlans({super.key});

  @override
  State<AIPlans> createState() => _AIPlansState();
}

class _AIPlansState extends State<AIPlans> {
  List<Plan> _plans = [];
  int cardColorIndex = 0;
  final Map<String, Color> _planColors = {};
  final List<Color> _cardColors = [
    HexColor.fromHex(ConfigProvider.getThemeConfig().primaryScheduleCardColor),
    HexColor.fromHex(
        ConfigProvider.getThemeConfig().secondaryScheduleCardColor),
  ];
  //TmiDateTime selectedDate = TmiDateTime.nowWithMinDate();
  CalendarController _calendarController = CalendarController();
  ValueNotifier<DateTime> _dateNotifier =
      ValueNotifier(TmiDateTime.nowWithMinDate().toDateTime());
  //var selectedView = CalendarView.day;
  var allowedViews = [CalendarView.day, CalendarView.week, CalendarView.month];
  @override
  initState() {
    super.initState();
    _calendarController = CalendarController();
    _calendarController.displayDate = TmiDateTime.nowWithMinDate().toDateTime();
    _dateNotifier.value = _calendarController.displayDate!;
    _calendarController.view = CalendarView.day;
    _calendarController.addPropertyChangedListener((p0) {
      if (p0 == "displayDate") {
        _dateNotifier.value = _calendarController.displayDate!;
        //
        Timer(const Duration(milliseconds: 300),
            () => _dateNotifier.notifyListeners());
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetchPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: "Tima AI",
      appBarTitleSize: 32,
      appBarBackgroundColor: HexColor.fromHex(
          ConfigProvider.getThemeConfig().scaffoldBackgroundColor),
      scaffoldBackgroundColor: Colors.white,
      centerWidget: Container(
          color: Colors.white,
          height: CustomScaffold.bodyHeight,
          child: SfCalendar(
            controller: _calendarController,
            showNavigationArrow: true,
            showTodayButton: true,
            key: UniqueKey(),
            allowViewNavigation: true,
            allowDragAndDrop: false,
            //view: selectedView,
            dataSource: MeetingDataSource(_plans),
            showCurrentTimeIndicator: true,
            appointmentBuilder: appointmentBuilder,
            timeSlotViewSettings: const TimeSlotViewSettings(
                timeIntervalHeight: 60, timeTextStyle: TextStyle(fontSize: 10)),
            headerHeight: 0,
            headerStyle: CalendarHeaderStyle(
                backgroundColor: HexColor.fromHex(
                    ConfigProvider.getThemeConfig().primaryScheduleCardColor)),
          )),
      bottomAppBar: getTmiBottomAppBar(context, ScreenType.AI,
          bgColor: HexColor.fromHex(
              ConfigProvider.getThemeConfig().scaffoldBackgroundColor),
          fgColor: Colors.white),
      actions: [
        ValueListenableBuilder(
            valueListenable: _dateNotifier,
            builder: (context, value, child) {
              return MyPlanDateSelector(
                key: UniqueKey(),
                (date) {
                  _calendarController.displayDate =
                      DateTime.fromMillisecondsSinceEpoch(
                          date.getMillisecondsSinceEpoch(),
                          isUtc: false);
                  _dateNotifier.value = _calendarController.displayDate!;
                },
                TmiDateTime(_dateNotifier.value.millisecondsSinceEpoch),
                weekView: _calendarController.view! == CalendarView.week,
              );
            })
      ],
      floatingActionButton: FloatingActionButton(
        tooltip: "Change view",
        shape: const CircleBorder(),
        backgroundColor: HexColor.fromHex(
            ConfigProvider.getThemeConfig().primaryThemeForegroundColor),
        onPressed: () {},
        child: PopupMenuButton<String>(
            tooltip: "Change view",
            icon: const Icon(Icons.calendar_view_day, color: Colors.white),
            onSelected: viewOptionSelected,
            itemBuilder: (context) => ["Day", "Week"]
                .map((e) => PopupMenuItem<String>(
                      value: e,
                      child: CustomText(text: e),
                    ))
                .toList()),
      ),
    );
  }

  void viewOptionSelected(String option) {
    if (option == "Day") {
      _calendarController.view = CalendarView.day;
    }
    if (option == "Week") {
      _calendarController.view = CalendarView.week;
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
              appointment.endTime.getMillisecondsSinceEpoch() -
                          appointment.startTime.getMillisecondsSinceEpoch() >=
                      30 * 60 * 1000
                  ? Expanded(
                      child: CustomText(
                        align: TextAlign.left,
                        text: appointment.title,
                        color: Colors.white,
                      ),
                    )
                  : Expanded(
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        child: CustomText(
                          align: TextAlign.left,
                          text: appointment.title,
                          color: Colors.white,
                        ),
                      ),
                    ),
              // appointment.endTime.getMillisecondsSinceEpoch() -
              //             appointment.startTime.getMillisecondsSinceEpoch() >=
              //         40 * 60 * 1000
              //     ? PopupMenuButton<String>(
              //         icon: Icon(Icons.adaptive.more, color: Colors.white),
              //         onSelected: (val) => optionSelected(val, appointment),
              //         itemBuilder: (context) =>
              //             ((TmiDateTime.now().getMillisecondsSinceEpoch() -
              //                             appointment.startTime
              //                                 .getMillisecondsSinceEpoch()) >=
              //                         0
              //                     ? ["Clone"]
              //                     : ["Clone", "Reai", "Remove"])
              //                 .map((e) => PopupMenuItem<String>(
              //                       value: e,
              //                       child: CustomText(text: e),
              //                     ))
              //                 .toList())
              //     : FittedBox(
              //         child: PopupMenuButton<String>(
              //             icon: Icon(Icons.adaptive.more, color: Colors.white),
              //             onSelected: (val) => optionSelected(val, appointment),
              //             itemBuilder: (context) => ((TmiDateTime.now()
              //                                 .getMillisecondsSinceEpoch() -
              //                             appointment.startTime
              //                                 .getMillisecondsSinceEpoch()) >=
              //                         0
              //                     ? ["Clone"]
              //                     : ["Clone", "Reai", "Remove"])
              //                 .map((e) => PopupMenuItem<String>(
              //                       value: e,
              //                       child: CustomText(text: e),
              //                     ))
              //                 .toList()),
              //       )
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
      if (Navigator.canPop(context)) Navigator.pop(context);
      fetchPlans();
    }, fullyEditable: true, title: "Plan Details", forceDialog: true);
  }

  // optionSelected(String val, Plan plan) {
  //   if (val == "Clone") {
  //     cloneTapped(plan);
  //   } else if (val == "Reai") {
  //     reaiTapped(plan);
  //   } else if (val == "Remove") {
  //     removePlanTapped(plan);
  //   }
  // }

  // void reaiTapped(Plan plan) {
  //   AddOrUpdatePlanRoute.push(context, plan, (p0) {
  //     setState(() {
  //       fetchPlans();
  //     });
  //   }, onlyTimeEditable: true, title: "Reai Plan", forceDialog: true);
  // }

  // void removePlanTapped(Plan plan) async {
  //   var proceed = await showShouldProceedDialog(
  //       "Delete", "Are you sure you want to remove this plan?", context);
  //   if (!proceed) return;
  //   var result = await Plan.deletePlan(plan.planId, context);
  //   if (result) {
  //     _plans.removeWhere((element) => element.planId == plan.planId);
  //     setState(() {});
  //   }
  // }

  // void cloneTapped(Plan plan) async {
  //   plan.planId = TmiDateTime.now().getMillisecondsSinceEpoch().toString();
  //   plan.startTime = plan.startTime.add(const Duration(days: 1));
  //   plan.endTime = plan.endTime.add(const Duration(days: 1));
  //   await PlanDashboardRoute.push(context,
  //       selectedPlan: plan,
  //       isCloneView: true,
  //       editPlanSectionTitle: "Clone My Plan",
  //       planListSectionTitle: "Cloned Plans");
  //   fetchPlans();
  // }
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

class AIPlansRoute {
  static Future push(BuildContext context, List<Plan> plans,
      void Function(Plan) onPlanUpdated) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const AIPlans()));
  }
}
