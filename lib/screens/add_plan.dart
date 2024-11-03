// ignore_for_file: use_build_context_synchronously, unused_import
import "dart:convert";

import "package:file_picker/file_picker.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:numberpicker/numberpicker.dart";
import "package:tmiui/config/config_provider.dart";
import "package:tmiui/config/theme.dart";
import "package:tmiui/custom_widgets/custom_column.dart";
import "package:tmiui/custom_widgets/custom_flat_button.dart";
import "package:tmiui/custom_widgets/custom_list_view.dart";
import "package:tmiui/custom_widgets/custom_snackbar.dart";
import "package:tmiui/custom_widgets/custom_text.dart";
import "package:tmiui/custom_widgets/grouping_container.dart";
import "package:tmiui/custom_widgets/text_field.dart";
import "package:tmiui/helpers/file_system.dart";
import "package:tmiui/helpers/uri.dart";
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
                    hintText: "Title",
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
                    text: "Add",
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
              leading: CustomFlatButton(
                  onTap: () {},
                  text:
                      plan.startTime.getTimeDifferenceInDuration(plan.endTime),
                  color: HexColor.fromHex(theme.primaryThemeForegroundColor)),
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
                          text:
                              "${plan.startTime.getTimeAsString()}, ${plan.startTime.getDateAsString()}",
                          color: HexColor.fromHex(
                              theme.primaryThemeForegroundColor))
                    ],
                  ),
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
                          text:
                              "${plan.endTime.getTimeAsString()}, ${plan.endTime.getDateAsString()}",
                          color: HexColor.fromHex(
                              theme.primaryThemeForegroundColor))
                    ],
                  )
                ],
              )),
          PlanBreaks(
            key: UniqueKey(),
            breaksUpdated: (breaks) => setState(() {
              breaks.sort((a, b) => a.startTime
                  .getMillisecondsSinceEpoch()
                  .compareTo(b.startTime.getMillisecondsSinceEpoch()));
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

  Future addWebLink({String locationHintText = "Hyperlink"}) async {
    await showDialog(
      context: context,
      builder: (context) => CustomForm(
          isDialog: true,
          formData: <String, CustomFormData>{
            locationHintText: CustomFormData(initialText: ""),
            "Title": CustomFormData(initialText: "")
          },
          title: "Add New Reference",
          submitText: "Done",
          onSubmit: (values) {
            var newReference = PlanReference.newReference(plan.planId);
            newReference.hyperlink = values[locationHintText].toString();
            newReference.description = values['Title'].toString();
            plan.planReferences.add(newReference);
            Navigator.pop(context);
          }),
    );
    setState(() {});
  }

  Future addLocalFile() async {
    if (kIsWeb) {
      var proceed = await showShouldProceedDialog(
          "Local reference",
          "Adding local reference is only supported in desktop/mobile version. You will have to add the file location manually in web version. Do you want to continue?",
          context);
      if (!proceed) return;
      await addWebLink(locationHintText: "File location");
      return;
    }
    var file = await FilePicker.platform.pickFiles();
    if (file == null) {
      return;
    }
    var newReference = PlanReference.newReference(plan.planId);
    newReference.hyperlink = file.files.single.path!;
    newReference.description = file.files.single.name;
    plan.planReferences.add(newReference);
    setState(() {});
  }

  void addReferenceTapped(String val) async {
    if (val == "Web link") {
      await addWebLink();
    } else if (val == "Local file") {
      await addLocalFile();
    }
  }

  Future chooseStartTimeTapped() async {
    var result = await chooseDateAndTime(context, fieldLableText: "Start Time");
    if (result == null) return;
    plan.startTime = result;
    plan.breaks.removeWhere((element) =>
        element.startTime.getMillisecondsSinceEpoch() <=
        plan.startTime.getMillisecondsSinceEpoch());
    setState(() {});
    showStartEndTimeValidationIfApplicable();
    showBreakTimingValidationWithRespectToPlanIfApplicable();
  }

  void showStartEndTimeValidationIfApplicable() {
    if (plan.startTime.getMillisecondsSinceEpoch() >=
        plan.endTime.getMillisecondsSinceEpoch()) {
      showSnackBarMessage(context,
          "Seems like the start time is ahead or same as end time. Please update the end time");
    }
  }

  void showBreakTimingValidationWithRespectToPlanIfApplicable() {
    var idx = plan.breaks.indexWhere(
        (e) => PlanBreak.validateBreakTimingsWithPlan(plan, e) != null);
    if (idx >= 0) {
      showSnackBarMessage(context,
          PlanBreak.validateBreakTimingsWithPlan(plan, plan.breaks[idx]) ?? "");
    }
  }

  Future chooseEndTimeTapped() async {
    var result = await chooseDateAndTime(context,
        fieldLableText: "End Time",
        firstDateTime: plan.startTime,
        initialDateTime: plan.startTime);
    if (result == null) return;
    plan.endTime = result;
    setState(() {});
    showStartEndTimeValidationIfApplicable();
    showBreakTimingValidationWithRespectToPlanIfApplicable();
  }

  saveButtonTapped() async {
    if (plan.endTime
            .toDateTime()
            .millisecondsSinceEpoch
            .compareTo(plan.startTime.toDateTime().millisecondsSinceEpoch) <=
        0) {
      await showMessageDialog("Invalid time",
          "Start time of the plan cannot be ahead of end time", context);
      return;
    }
    var requestPlan = plan;
    requestPlan.title = _titleController.text.trim();
    requestPlan.description = _descriptionController.text.trim();
    Plan? result;
    print(jsonEncode(requestPlan));
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
    if (UriHelper.isValidUrl(url)) {
      await launchUrlString(url);
    } else {
      await AppFile.openFile(url, context);
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
    breaks.sort((a, b) => a.startTime
        .getMillisecondsSinceEpoch()
        .compareTo(b.startTime.getMillisecondsSinceEpoch()));
    return GroupingContainer(
        leading: PopupMenuButton<String>(
          onSelected: breakOptionSelected,
          itemBuilder: (context) =>
              ["Use pomodoro", "Custom break", "Clear all"]
                  .map((e) => PopupMenuItem<String>(
                        value: e,
                        child: CustomText(text: e),
                      ))
                  .toList(),
          child: CustomFlatButton(
              text: "Manage",
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
    var st = widget.plan.startTime;
    var et = widget.plan.endTime;
    bool showDatePicker = st.toDateTime().day != et.toDateTime().day;
    PlanBreak? newBreak;
    if (showDatePicker) {
      var startTime = await chooseDateAndTime(context,
          fieldLableText: "Choose break start time",
          initialDateTime: widget.plan.startTime,
          firstDateTime: widget.plan.startTime,
          lastDateTime: widget.plan.endTime);
      if (startTime == null) return;
      var endTime = await chooseDateAndTime(context,
          fieldLableText: "Choose break end time",
          firstDateTime: startTime,
          initialDateTime: startTime,
          lastDateTime: widget.plan.endTime);
      if (endTime == null) return;
      newBreak = PlanBreak(startTime, endTime);
    } else {
      var startTime = await chooseTime(context, widget.plan.startTime,
          fieldLabelText: "Choose break start time");
      var endTime = await chooseTime(context, widget.plan.endTime,
          fieldLabelText: "Choose break end time");
      if (startTime == null || endTime == null) return;
      newBreak = PlanBreak(startTime, endTime);
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

  void breakOptionSelected(String value) async {
    if (value == "Custom break") {
      addNewBreakTapped();
    } else if (value == "Use pomodoro") {
      if (breaks.isNotEmpty) {
        var proceed = await showShouldProceedDialog(
            "Use Pomodoro",
            "Using pomodoro will override the current breaks. Are you sure you want to proceed?",
            context);
        if (!proceed) return;
      }
      applyPomodoro();
    } else if (value == "Clear all") {
      if (breaks.isNotEmpty) {
        var proceed = await showShouldProceedDialog("Confirm",
            "Are you sure you want to clear all the breaks?", context);
        if (!proceed) return;
      }
      breaks.clear();
      widget.breaksUpdated(breaks);
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
                  appBarTitleSize: 32,
                  scaffoldBackgroundColor: HexColor.fromHex(
                      ConfigProvider.getThemeConfig().scaffoldBackgroundColor),
                  centerWidget: AddOrUpdatePlan(plan, onNewPlanAdded),
                )));
  }
}
