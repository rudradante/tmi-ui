import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:tmiui/config/config_provider.dart';
import 'package:tmiui/custom_widgets/custom_text.dart';
import 'package:tmiui/extensions/color.dart';
import 'package:tmiui/models.dart/plan.dart';
import 'package:tmiui/models.dart/plan_review.dart';
import 'package:tmiui/screens/add_plan.dart';
import 'package:tmiui/screens/plan_dashboard.dart';
import 'package:tmiui/screens/screen_types.dart';

import '../custom_widgets/bottom_appbar.dart';
import '../custom_widgets/custom_dialog.dart';
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
  final ValueNotifier<DateTime> _dateNotifier =
      ValueNotifier(TmiDateTime.nowWithMinDate().toDateTime());
  var allowedViews = [CalendarView.schedule];
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
        key: UniqueKey(),
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
  bool isShortPlan = false;
  bool showActionButtons = true;

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
    var progressColor = color;
    isShortPlan = widget.calendarAppointmentDetails.bounds.height < 30;
    if (widget.calendarAppointmentDetails.bounds.height < 28) {
      showActionButtons = false;
    }

    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(0),
      width: widget.calendarAppointmentDetails.bounds.width,
      height: widget.calendarAppointmentDetails.bounds.height,
      child: Row(
        children: [
          Expanded(
            child: Tooltip(
              message: appointment.title,
              child: InkWell(
                onDoubleTap: () => planDoubleTapped(appointment),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        decoration: BoxDecoration(
                          color: inReviewMode ? Colors.white : color,
                          borderRadius:
                              appointment.review != null && !isShortPlan
                                  ? const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(8))
                                  : BorderRadius.circular(8),
                        ),
                        margin: EdgeInsets.zero,
                        padding: EdgeInsets.zero,
                        width:
                            widget.calendarAppointmentDetails.bounds.width - 80,
                        height: appointment.review == null || isShortPlan
                            ? widget.calendarAppointmentDetails.bounds.height
                            : (2 / 3) *
                                    widget.calendarAppointmentDetails.bounds
                                        .height -
                                2,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: inReviewMode
                                    ? Slider(
                                        divisions: 100,
                                        min: 0,
                                        max: 100,
                                        label: (percentage).toString(),
                                        value: (percentage).toDouble(),
                                        onChanged: (value) {
                                          percentage = value.round();
                                          setState(() {});
                                        },
                                      )
                                    : wrapInFittedBox(
                                        CustomText(
                                          align: TextAlign.left,
                                          text: appointment.title,
                                          color: Colors.white,
                                        ),
                                        isShortPlan),
                              ),
                            ),
                            appointment.review != null || inReviewMode
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0, right: 4),
                                    child: wrapInFittedBox(
                                        CustomText(
                                          color: inReviewMode
                                              ? null
                                              : Colors.white,
                                          text: "$percentage%",
                                          //size: 14,
                                        ),
                                        isShortPlan),
                                  )
                                : const SizedBox(),
                          ],
                        )),
                    appointment.review != null && !isShortPlan
                        ? Container(
                            margin: EdgeInsets.zero,
                            padding: EdgeInsets.zero,
                            width:
                                widget.calendarAppointmentDetails.bounds.width -
                                    80,
                            color: Colors.white,
                            height: 2)
                        : SizedBox(),
                    inReviewMode || appointment.review == null || isShortPlan
                        ? const SizedBox()
                        : LinearPercentIndicator(
                            backgroundColor: Colors.blueGrey[200],
                            animation: true,
                            padding: EdgeInsets.zero,
                            barRadius: const Radius.circular(8),
                            width:
                                widget.calendarAppointmentDetails.bounds.width -
                                    80,
                            lineHeight: (1 / 3) *
                                widget.calendarAppointmentDetails.bounds.height,
                            percent: percentage / 100,
                            progressColor: progressColor,
                          )
                  ],
                ),
              ),
            ),
          ),
          !showActionButtons
              ? SizedBox()
              : InkWell(
                  // padding: EdgeInsets.zero,
                  // tooltip: ,
                  onTap: () => inReviewMode
                      ? widget.onReviewSaved(appointment.planId, percentage)
                      : enableReviewTapped(
                          appointment.planId, appointment.review?.updatedCount),
                  child: Container(
                    height: 28,
                    width: 28,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(4),
                    //     ? EdgeInsets.all(10)
                    //:,
                    margin: EdgeInsets.zero,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            width: 2,
                            color: (appointment.review?.updatedCount ?? 0) == 3
                                ? HexColor.fromHex(
                                    ConfigProvider.getThemeConfig()
                                        .inactiveTextColor)
                                : HexColor.fromHex(
                                    ConfigProvider.getThemeConfig()
                                        .primaryThemeForegroundColor))),
                    child: Tooltip(
                        message: inReviewMode ? "Save" : "Update review",
                        child: !inReviewMode
                            ? wrapInFittedBox(
                                CustomText(
                                    fontWeight: FontWeight.w500,
                                    text:
                                        (3 - (appointment.review?.updatedCount ?? 0))
                                            .toString(),
                                    size: 14,
                                    color: (appointment.review?.updatedCount ?? 0) == 3
                                        ? HexColor.fromHex(
                                            ConfigProvider.getThemeConfig()
                                                .inactiveTextColor)
                                        : HexColor.fromHex(
                                            ConfigProvider.getThemeConfig()
                                                .primaryThemeForegroundColor)),
                                true)
                            : Icon(Icons.check,
                                size: 14,
                                color: HexColor.fromHex(
                                    ConfigProvider.getThemeConfig()
                                        .primaryThemeForegroundColor))),
                  )),
          const SizedBox(width: 12),
          !showActionButtons
              ? SizedBox()
              : inReviewMode
                  ? InkWell(
                      onTap: () => setState(() {
                            percentage = appointment.review?.percentage ?? 0;
                            _reviewing.remove(appointment.planId);
                          }),
                      child: Container(
                          height: 28,
                          width: 28,
                          padding: const EdgeInsets.all(4),
                          margin: EdgeInsets.zero,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  width: 2,
                                  color: HexColor.fromHex(
                                      ConfigProvider.getThemeConfig()
                                          .primaryThemeForegroundColor))),
                          child: Tooltip(
                              message: "Reset",
                              child: Icon(Icons.undo,
                                  size: 14,
                                  color: HexColor.fromHex(
                                      ConfigProvider.getThemeConfig()
                                          .primaryThemeForegroundColor)))))
                  : const SizedBox(),
          !showActionButtons
              ? SizedBox()
              : !inReviewMode
                  ? wrapInFittedBox(
                      Container(
                          height: 28,
                          width: 28,
                          padding: const EdgeInsets.all(4),
                          margin: EdgeInsets.zero,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  width: 2,
                                  color: HexColor.fromHex(
                                      ConfigProvider.getThemeConfig()
                                          .primaryThemeForegroundColor))),
                          child: Tooltip(
                              message: inReviewMode ? "Save" : "Update review",
                              child: SvgPicture.asset('assets/icons/ai.svg',
                                  height: 14, width: 14))),
                      isShortPlan)
                  : const SizedBox()
        ],
      ),
    );
  }

  enableReviewTapped(String planId, int? updatedCount) {
    if (updatedCount != null && updatedCount >= 3) {
      //showMessageDialog("", "You can only edit a review for 3 times", context);
      return;
    }
    _reviewing.remove(planId);
    _reviewing.putIfAbsent(planId, () => true);
    setState(() {});
  }

  void planDoubleTapped(Plan plan) async {
    // if (!isShortPlan) {
    //   AddOrUpdatePlanRoute.push(context, plan, (p0) {},
    //       notEditable: true, title: "Plan Details", forceDialog: true);
    //   return;
    // }
    showDialog(
        context: context,
        builder:
            (context) =>
                StatefulBuilder(builder: (context, StateSetter setState) {
                  return CustomDialog(
                    title: plan.title,
                    content: ReviewPercentagePicker(
                        percentage: percentage,
                        onChange: (p) => percentage = p),
                    actions: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          widget.onReviewSaved(plan.planId, percentage);
                        },
                        child: Container(
                          height: 28,
                          width: 28,
                          padding: const EdgeInsets.all(4),
                          margin: EdgeInsets.zero,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  width: 2,
                                  color: HexColor.fromHex(
                                      ConfigProvider.getThemeConfig()
                                          .primaryThemeForegroundColor))),
                          child: Tooltip(
                              message: "Save",
                              child: Icon(Icons.check,
                                  size: 14,
                                  color: HexColor.fromHex(
                                      ConfigProvider.getThemeConfig()
                                          .primaryThemeForegroundColor))),
                        ),
                      ),
                      Container(
                          height: 28,
                          width: 28,
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(4),
                          margin: EdgeInsets.zero,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  width: 2,
                                  color: (plan.review?.updatedCount ?? 0) == 3
                                      ? HexColor.fromHex(
                                          ConfigProvider.getThemeConfig()
                                              .inactiveTextColor)
                                      : HexColor.fromHex(
                                          ConfigProvider.getThemeConfig()
                                              .primaryThemeForegroundColor))),
                          child: wrapInFittedBox(
                              CustomText(
                                  fontWeight: FontWeight.w500,
                                  text: (3 - (plan.review?.updatedCount ?? 0))
                                      .toString(),
                                  size: 14,
                                  color: (plan.review?.updatedCount ?? 0) == 3
                                      ? HexColor.fromHex(
                                          ConfigProvider.getThemeConfig().inactiveTextColor)
                                      : HexColor.fromHex(ConfigProvider.getThemeConfig().primaryThemeForegroundColor)),
                              true)),
                      Container(
                          height: 28,
                          width: 28,
                          padding: const EdgeInsets.all(4),
                          margin: EdgeInsets.zero,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  width: 2,
                                  color: HexColor.fromHex(
                                      ConfigProvider.getThemeConfig()
                                          .primaryThemeForegroundColor))),
                          child: Tooltip(
                              message: "AI",
                              child: SvgPicture.asset('assets/icons/ai.svg',
                                  height: 14, width: 14))),
                    ],
                  );
                }));
  }
}

class ReviewPercentagePicker extends StatefulWidget {
  const ReviewPercentagePicker(
      {super.key, required this.percentage, required this.onChange});

  final int percentage;
  final void Function(int) onChange;

  @override
  State<ReviewPercentagePicker> createState() => _ReviewPercentagePickerState();
}

class _ReviewPercentagePickerState extends State<ReviewPercentagePicker> {
  int percentage = 0;

  @override
  void initState() {
    super.initState();
    percentage = widget.percentage;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(
      children: [
        Expanded(
            child: Slider(
          divisions: 100,
          min: 0,
          max: 100,
          label: (percentage).toString(),
          value: (percentage).toDouble(),
          onChanged: (value) {
            percentage = value.round();
            setState(() {});
            widget.onChange(percentage);
          },
        )),
        CustomText(
          text: "$percentage%",
          //size: 14,
        ),
      ],
    ));
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

Widget wrapInFittedBox(Widget child, bool wrap) =>
    wrap ? FittedBox(alignment: Alignment.centerLeft, child: child) : child;
