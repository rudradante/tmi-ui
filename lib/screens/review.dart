import 'dart:async';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:tmiui/config/config_provider.dart';
import 'package:tmiui/custom_widgets/custom_text.dart';
import 'package:tmiui/custom_widgets/message_dialog.dart';
import 'package:tmiui/extensions/color.dart';
import 'package:tmiui/models.dart/plan.dart';
import 'package:tmiui/models.dart/plan_review.dart';
import 'package:tmiui/screens/add_plan.dart';
import 'package:tmiui/screens/plan_dashboard.dart';
import 'package:tmiui/screens/screen_types.dart';

import '../custom_widgets/bottom_appbar.dart';
import '../custom_widgets/custom_row.dart';
import '../custom_widgets/custom_scaffold.dart';
import '../models.dart/tmi_datetime.dart';

Map<String, bool> _reviewing = {};
int cardColorIndex = 0;
final List<Color> _cardColors = [
  HexColor.fromHex(ConfigProvider.getThemeConfig().primaryScheduleCardColor),
  HexColor.fromHex(ConfigProvider.getThemeConfig().secondaryScheduleCardColor),
];
final Map<String, Color> _planColors = {};

class ReviewPlans extends StatefulWidget {
  const ReviewPlans({Key? key}) : super(key: key);

  @override
  State<ReviewPlans> createState() => _ReviewPlansState();
}

class _ReviewPlansState extends State<ReviewPlans> {
  List<Plan> _plans = [];
  CalendarController _calendarController = CalendarController();
  ValueNotifier<DateTime> _dateNotifier =
      ValueNotifier(TmiDateTime.nowWithMinDate().toDateTime());
  var allowedViews = [CalendarView.day];
  @override
  initState() {
    super.initState();
    _reviewing.clear();
    _planColors.clear();
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
      title: "My Reviews",
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
      bottomAppBar: getTmiBottomAppBar(context, ScreenType.Review,
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
    );
  }

  Widget appointmentBuilder(BuildContext context,
      CalendarAppointmentDetails calendarAppointmentDetails) {
    return ReviewCardWidget(
        calendarAppointmentDetails: calendarAppointmentDetails,
        onReviewSaved: reviewUpdated);
  }

  void fetchPlans() async {
    _reviewing.clear();
    _plans = await Plan.getAllPlans(null, context);
    setState(() {});
  }

  void reviewUpdated(String planId, int percent) async {
    var request = PlanReview(
        TmiDateTime.now().getMillisecondsSinceEpoch().toString(),
        planId,
        TmiDateTime.now(),
        percent,
        0);
    var result = await PlanReview.updateReview(request, context);
    if (result == null) return;
    _reviewing.remove(planId);
    _planColors.remove(planId);
    fetchPlans();
  }
}

class ReviewCardWidget extends StatefulWidget {
  const ReviewCardWidget(
      {super.key,
      required this.calendarAppointmentDetails,
      required this.onReviewSaved});
  final CalendarAppointmentDetails calendarAppointmentDetails;
  final void Function(String, int) onReviewSaved;

  @override
  State<ReviewCardWidget> createState() => _ReviewCardWidgetState();
}

class _ReviewCardWidgetState extends State<ReviewCardWidget> {
  int percentage = 0;

  @override
  void initState() {
    percentage = (widget.calendarAppointmentDetails.appointments.first as Plan)
            .review
            ?.percentage ??
        0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Plan appointment =
        widget.calendarAppointmentDetails.appointments.first;
    bool inReviewMode = _reviewing.containsKey(appointment.planId);

    var color = appointment.review == null
        ? HexColor.fromHex(
            ConfigProvider.getThemeConfig().pastScheduleCardColor)
        : _planColors.containsKey(appointment.planId)
            ? _planColors[appointment.planId]
            : _cardColors[(cardColorIndex++) % _cardColors.length];
    _planColors.putIfAbsent(appointment.planId, () => color!);

    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(0),
      width: widget.calendarAppointmentDetails.bounds.width,
      height: widget.calendarAppointmentDetails.bounds.height,
      child: Stack(
        children: [
          Tooltip(
            message: appointment.title,
            child: InkWell(
              onDoubleTap: () => planDoubleTapped(appointment),
              child: appointment.review == null
                  ? Container(
                      decoration: BoxDecoration(
                          color: inReviewMode ? Colors.white : color,
                          borderRadius: BorderRadius.circular(8)),
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.zero,
                      width:
                          widget.calendarAppointmentDetails.bounds.width - 40,
                      height: widget.calendarAppointmentDetails.bounds.height,
                      //color: Colors.white,
                    )
                  : CustomRow(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: inReviewMode ? Colors.white : color,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8)),
                              border: Border.all(
                                  color: inReviewMode ? Colors.white : color!,
                                  width: 0.5)),
                          margin: EdgeInsets.zero,
                          padding: EdgeInsets.zero,
                          width: (percentage /
                              100 *
                              (widget.calendarAppointmentDetails.bounds.width -
                                  40)),
                          height:
                              widget.calendarAppointmentDetails.bounds.height,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(8),
                                  bottomRight: Radius.circular(8)),
                              border: Border.all(
                                  color: inReviewMode ? Colors.white : color!,
                                  width: 0.5)),
                          margin: EdgeInsets.zero,
                          padding: EdgeInsets.zero,
                          width: ((100 - percentage) /
                              100 *
                              (widget.calendarAppointmentDetails.bounds.width -
                                  40)),
                          height:
                              widget.calendarAppointmentDetails.bounds.height,
                          //color: Colors.white,
                        ),
                      ],
                    ),
            ),
          ),
          Positioned(
            height: widget.calendarAppointmentDetails.bounds.height,
            width: widget.calendarAppointmentDetails.bounds.width,
            child: Row(
              children: [
                !inReviewMode
                    ? appointment.endTime.getMillisecondsSinceEpoch() -
                                appointment.startTime
                                    .getMillisecondsSinceEpoch() >=
                            3600000
                        ? Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CustomText(
                                align: TextAlign.left,
                                text: appointment.title,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: FittedBox(
                                alignment: Alignment.centerLeft,
                                child: CustomText(
                                  align: TextAlign.left,
                                  text: appointment.title,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                    : Expanded(
                        child: Slider(
                        divisions: 100,
                        min: 0,
                        max: 100,
                        label: (percentage).toString(),
                        value: (percentage).toDouble(),
                        onChanged: (value) {
                          percentage = value.round();
                          setState(() {});
                        },
                      )),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        tooltip: inReviewMode ? "Save" : "Update review",
                        onPressed: () => inReviewMode
                            ? widget.onReviewSaved(
                                appointment.planId, percentage)
                            : enableReviewTapped(appointment.planId,
                                appointment.review?.updatedCount),
                        icon: Icon(
                            appointment.review == null
                                ? Icons.check
                                : inReviewMode
                                    ? Icons.check
                                    : Icons.check_circle,
                            color: HexColor.fromHex(
                                ConfigProvider.getThemeConfig()
                                    .primaryThemeForegroundColor))),
                    appointment.review == null
                        ? const SizedBox()
                        : CustomText(
                            text: "$percentage%",
                            size: 10,
                          )
                  ],
                ),
                inReviewMode
                    ? IconButton(
                        tooltip: "Reset",
                        onPressed: () => setState(() {
                              percentage = appointment.review?.percentage ?? 0;
                              _reviewing.remove(appointment.planId);
                            }),
                        icon: Icon(Icons.undo,
                            color: HexColor.fromHex(
                                ConfigProvider.getThemeConfig()
                                    .primaryThemeForegroundColor)))
                    : const SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  enableReviewTapped(String planId, int? updatedCount) {
    if (updatedCount != null && updatedCount >= 3) {
      showMessageDialog("", "You can only edit a review for 3 times", context);
      return;
    }
    _reviewing.remove(planId);
    _reviewing.putIfAbsent(planId, () => true);
    setState(() {});
  }

  void planDoubleTapped(Plan plan) async {
    AddOrUpdatePlanRoute.push(context, plan, (p0) {},
        notEditable: true, title: "Plan Details", forceDialog: true);
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

class ReviewPlansRoute {
  static Future push(BuildContext context, List<Plan> plans) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const ReviewPlans()));
  }
}
