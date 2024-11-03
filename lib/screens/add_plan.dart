// ignore_for_file: use_build_context_synchronously, unused_import
import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:numberpicker/numberpicker.dart";
import "package:tmiui/config/config_provider.dart";
import "package:tmiui/config/theme.dart";
import "package:tmiui/custom_widgets/custom_column.dart";
import "package:tmiui/custom_widgets/custom_flat_button.dart";
import "package:tmiui/custom_widgets/custom_list_view.dart";
import "package:tmiui/custom_widgets/custom_text.dart";
import "package:tmiui/custom_widgets/grouping_container.dart";
import "package:tmiui/custom_widgets/text_field.dart";
import "package:tmiui/models.dart/plan.dart";
import "package:tmiui/models.dart/plan_references.dart";
import "package:tmiui/models.dart/tmi_datetime.dart";
import "package:tmiui/server/request.dart";
import "package:url_launcher/url_launcher.dart";
import "package:url_launcher/url_launcher_string.dart";

import "../custom_widgets/custom_form_dialog.dart";
import "../custom_widgets/custom_row.dart";
import "../custom_widgets/custom_scaffold.dart";
import "../custom_widgets/message_dialog.dart";
import "../custom_widgets/should_proceed_dialog.dart";
import "../extensions/color.dart";
import "../extensions/time_of_day.dart";
import "../helpers/date_time.dart";
import "../models.dart/plan_break.dart";

class AddOrUpdatePlan extends StatefulWidget {
  const AddOrUpdatePlan(this.plan, this.newPlanAdded, {Key? key})
      : super(key: key);
  final void Function(Plan) newPlanAdded;
  final Plan plan;

  @override
  State<AddOrUpdatePlan> createState() => _AddOrUpdatePlanState();
}

class _AddOrUpdatePlanState extends State<AddOrUpdatePlan> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Plan plan = Plan.newPlan();
  @override
  void initState() {
    super.initState();
    plan = widget.plan;
    _titleController.text = widget.plan.title;
    _descriptionController.text = widget.plan.description;
  }

  @override
  Widget build(BuildContext context) {
    var sf = calculateScreenFactors(context);
    var theme = ConfigProvider.getThemeConfig();
    var elevatedContainer = true;
    return SizedBox(
      width: 400 * sf.cf,
      child: CustomColumn(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GroupingContainer(
              elevated: elevatedContainer,
              label: "Plan Details",
              subtitle: "Add details about the task you are adding",
              child: CustomColumn(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    controller: _titleController,
                    label: "Title",
                    hintText: "What you want to do?",
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  CustomTextField(
                    controller: _descriptionController,
                    maxLines: 10,
                    hintText: "Add any other notes or description for the task",
                  )
                ],
              )),
          GroupingContainer(
              label: "References",
              height: 250,
              leading: PopupMenuButton<String>(
                onSelected: addReferenceTapped,
                itemBuilder: (context) => ["Web link", "Local file"]
                    .map((e) => PopupMenuItem<String>(
                          value: e,
                          child: CustomText(text: e),
                        ))
                    .toList(),
                child: CustomFlatButton(
                    text: "Add Reference",
                    color: HexColor.fromHex(theme.primaryThemeForegroundColor)),
              ),
              subtitle: "Add local or web locations of files",
              elevated: elevatedContainer,
              child: CustomListView(
                  itemBuilder: (context, i) {
                    return CustomRow(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Tooltip(
                          preferBelow: true,
                          message: plan.planReferences[i].hyperlink,
                          child: InkWell(
                            onTap: () => referenceTapped(
                                plan.planReferences[i].hyperlink),
                            child: CustomText(
                                align: TextAlign.left,
                                text: plan.planReferences[i].description,
                                color: Colors.lightBlue,
                                underlined: true),
                          ),
                        ),
                        IconButton(
                            onPressed: () => deleteReferenceTapped(
                                plan.planReferences[i].planReferenceId),
                            icon: const Icon(
                              Icons.remove,
                              color: Colors.red,
                            ))
                      ],
                    );
                  },
                  itemCount: plan.planReferences.length)),
          GroupingContainer(
              elevated: elevatedContainer,
              label: "Schedule",
              subtitle: "Choose when you start and end this task",
              child: CustomRow(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomColumn(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CustomText(text: "Starts from"),
                      const SizedBox(
                        height: 4,
                      ),
                      CustomFlatButton(
                          isOutlined: true,
                          onTap: chooseStartTimeTapped,
                          text: plan.startTime.getTimeAsString(),
                          color: HexColor.fromHex(
                              theme.primaryThemeForegroundColor))
                    ],
                  ),
                  CustomFlatButton(
                      onTap: () {},
                      text: plan.startTime
                          .getTimeDifferenceInDuration(plan.endTime),
                      color:
                          HexColor.fromHex(theme.primaryThemeForegroundColor)),
                  CustomColumn(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CustomText(text: "Ends at"),
                      const SizedBox(
                        height: 4,
                      ),
                      CustomFlatButton(
                          isOutlined: true,
                          onTap: chooseEndTimeTapped,
                          text: plan.endTime.getTimeAsString(),
                          color: HexColor.fromHex(
                              theme.primaryThemeForegroundColor))
                    ],
                  )
                ],
              )),
          PlanBreaks(
            key: UniqueKey(),
            breaksUpdated: (breaks) => setState(() {
              plan.breaks = breaks;
            }),
            plan: plan,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomRow(mainAxisSize: MainAxisSize.max, children: [
              Expanded(
                child: CustomFlatButton(
                  elevated: true,
                  onTap: saveButtonTapped,
                  color: HexColor.fromHex(theme.primaryButtonColor),
                  text: "Save",
                ),
              ),
            ]),
          )
        ],
      ),
    );
  }

  Future deleteReferenceTapped(String id) async {
    var shouldProceed = await showShouldProceedDialog("Confirm Deletion",
        "Are you sure you want to remove this reference?", context);
    if (!shouldProceed) return;
    plan.planReferences.removeWhere((element) => element.planReferenceId == id);
    setState(() {});
  }

  void addReferenceTapped(String val) async {
    if (val == "Web link") {
      await showDialog(
        context: context,
        builder: (context) => CustomForm(
            isDialog: true,
            formData: <String, CustomFormData>{
              "Hyperlink": CustomFormData(initialText: ""),
              "Title": CustomFormData(initialText: "")
            },
            title: "Add Reference",
            submitText: "Add",
            onSubmit: (values) {
              var newReference = PlanReference.newReference(plan.planId);
              newReference.hyperlink = values['Hyperlink'].toString();
              newReference.description = values['Title'].toString();
              plan.planReferences.add(newReference);
              Navigator.pop(context);
            }),
      );

      setState(() {});
    } else if (val == "Local file") {
      var file = await FilePicker.platform.pickFiles();
      print(file == null);
      if (file == null) {
        return;
      }
      print(file.paths.single == null);
      print(file.paths.single);
      var newReference = PlanReference.newReference(plan.planId);
      newReference.hyperlink = file.files.single.path!;
      newReference.description = file.files.single.name;
      plan.planReferences.add(newReference);
      Navigator.pop(context);

      setState(() {});
    }
  }

  Future chooseStartTimeTapped() async {
    var result = await chooseDateAndTime(context);
    if (result == null) return;
    plan.startTime = result;
    plan.breaks.removeWhere((element) =>
        element.startTime.getMillisecondsSinceEpoch() <=
        plan.startTime.getMillisecondsSinceEpoch());
    setState(() {});
  }

  Future chooseEndTimeTapped() async {
    var result = await chooseDateAndTime(context);
    if (result == null) return;
    plan.endTime = result;
    plan.breaks.removeWhere((element) =>
        element.endTime.getMillisecondsSinceEpoch() >=
        plan.endTime.getMillisecondsSinceEpoch());
    setState(() {});
  }

  saveButtonTapped() async {
    if (plan.endTime
            .toDateTime()
            .millisecondsSinceEpoch
            .compareTo(plan.startTime.toDateTime().millisecondsSinceEpoch) <=
        0) {
      await showMessageDialog(
          "Invalid time", "Start time cannot be ahead of end time", context);
      return;
    }
    var requestPlan = plan;
    requestPlan.title = _titleController.text.trim();
    requestPlan.description = _descriptionController.text.trim();
    Plan? result;
    if (int.tryParse(plan.planId) != null) {
      result = await Plan.createPlan(requestPlan, context);
    } else {
      result = await Plan.updatePlan(requestPlan, context);
    }
    if (result == null) return;
    plan = result;
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    widget.newPlanAdded(plan);
  }

  void referenceTapped(String url) async {
    try {
      bool result = await launchUrlString(url);
      if (!result) throw new Exception();
    } catch (err) {
      print(err);
      await showMessageDialog(
          "Invalid url", "Cannot open the reference", context);
    }
  }
}

class PlanBreaks extends StatefulWidget {
  final Plan plan;
  final Function(List<PlanBreak>) breaksUpdated;
  const PlanBreaks({Key? key, required this.plan, required this.breaksUpdated})
      : super(key: key);

  @override
  State<PlanBreaks> createState() => _PlanBreaksState();
}

class _PlanBreaksState extends State<PlanBreaks> {
  List<PlanBreak> breaks = [];
  @override
  void initState() {
    super.initState();
    breaks = widget.plan.breaks;
  }

  @override
  Widget build(BuildContext context) {
    var theme = ConfigProvider.getThemeConfig();
    return GroupingContainer(
        leading: PopupMenuButton<String>(
          onSelected: breakOptionSelected,
          itemBuilder: (context) => ["Add Break", "Use Pomodoro"]
              .map((e) => PopupMenuItem<String>(
                    value: e,
                    child: CustomText(text: e),
                  ))
              .toList(),
          child: CustomFlatButton(
              text: "Add Break",
              color: HexColor.fromHex(theme.primaryThemeForegroundColor)),
        ),
        elevated: true,
        label: "Breaks",
        subtitle: "Take breaks to increase efficiency",
        child: CustomColumn(
          mainAxisSize: MainAxisSize.min,
          children: breaks
              .map((e) => CustomRow(
                    children: [
                      Expanded(
                        child: CustomRow(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomFlatButton(
                                text: e.startTime.getTimeAsString(),
                                isOutlined: true,
                                color: Colors.green),
                            CustomText(
                                text: e.startTime
                                    .getTimeDifferenceInDuration(e.endTime)),
                            CustomFlatButton(
                                isOutlined: true,
                                text: e.endTime.getTimeAsString(),
                                color: Colors.green),
                          ],
                        ),
                      ),
                      IconButton(
                          onPressed: () => removeBreakTapped(e),
                          icon: const Icon(Icons.remove, color: Colors.red))
                    ],
                  ))
              .toList(),
        ));
  }

  void applyPomodoro() {
    breaks = [];
    int currentTime = widget.plan.startTime.getMillisecondsSinceEpoch();
    while (currentTime + 30 * 60000 <=
        widget.plan.endTime.getMillisecondsSinceEpoch()) {
      currentTime += 25 * 60000;
      breaks.add(PlanBreak(
          TmiDateTime(currentTime), TmiDateTime(currentTime + 5 * 60000)));
      currentTime += 5 * 60000;
    }
    //setState(() {});
    widget.breaksUpdated(breaks);
  }

  void addNewBreakTapped() async {
    var st = widget.plan.startTime.toDateTime();
    var et = widget.plan.endTime.toDateTime();
    bool showDatePicker = st.day != et.day;
    PlanBreak? newBreak;
    if (showDatePicker) {
      var startTime =
          await chooseDateAndTime(context, fieldLableText: "Choose start time");
      if (startTime == null) return;
      var endTime =
          await chooseDateAndTime(context, fieldLableText: "Choose end time");
      if (endTime == null) return;
      newBreak = PlanBreak(startTime, endTime);
    } else {
      var startTime = await showTimePicker(
          context: context, initialTime: widget.plan.startTime.toTimeOfDay());
      var endTime = await showTimePicker(
          context: context, initialTime: widget.plan.endTime.toTimeOfDay());
      if (startTime == null || endTime == null) return;
      var startTmiTime =
          DateTime(st.year, st.month, st.day, startTime.hour, startTime.minute);
      var endTmiTime =
          DateTime(et.year, et.month, et.day, endTime.hour, endTime.minute);
      var finalSt = TmiDateTime(startTmiTime.millisecondsSinceEpoch);
      var finalEt = TmiDateTime(endTmiTime.millisecondsSinceEpoch);
      newBreak = PlanBreak(finalSt, finalEt);
    }
    var error = PlanBreak.validateBreakTimingsWithPlan(widget.plan, newBreak);
    if (error != null) {
      await showMessageDialog("Invalid break", error, context);
      return;
    }
    breaks.add(newBreak);
    widget.breaksUpdated(breaks);
    setState(() {});
  }

  void breakOptionSelected(String value) {
    if (value == "Add Break") {
      addNewBreakTapped();
    } else if (value == "Use Pomodoro") {
      applyPomodoro();
    }
  }

  removeBreakTapped(PlanBreak e) {
    breaks.removeWhere((t) => t.id == e.id);

    widget.breaksUpdated(breaks);
    setState(() {});
  }
}

class AddOrUpdatePlanRoute {
  static void push(
      BuildContext context, Plan plan, void Function(Plan) onNewPlanAdded) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CustomScaffold(
                  title: "Let's add a plan",
                  appBarTitleSize: 40,
                  scaffoldBackgroundColor: HexColor.fromHex(
                      ConfigProvider.getThemeConfig().scaffoldBackgroundColor),
                  centerWidget: AddOrUpdatePlan(plan, onNewPlanAdded),
                )));
  }
}
