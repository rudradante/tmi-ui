import 'package:flutter/material.dart';
import 'package:tmiui/config/config_provider.dart';
import 'package:tmiui/config/theme.dart';
import 'package:tmiui/custom_widgets/custom_column.dart';
import 'package:tmiui/custom_widgets/should_proceed_dialog.dart';
import 'package:tmiui/custom_widgets/text_field.dart';
import 'package:tmiui/models.dart/plan_note.dart';
import 'package:tmiui/models.dart/tmi_datetime.dart';

import '../custom_widgets/custom_row.dart';
import '../custom_widgets/custom_text.dart';
import '../extensions/color.dart';
import '../models.dart/plan.dart';

class MyPlanCard extends StatefulWidget {
  final Plan plan;
  final bool isSelected;
  final Function(Plan) onPlanSelected;
  final Function(String) onPlanDeleted;
  final bool readonly;
  const MyPlanCard(this.plan, this.onPlanSelected, this.onPlanDeleted,
      this.isSelected, this.readonly,
      {Key? key})
      : super(key: key);

  @override
  State<MyPlanCard> createState() => _MyPlanCardState();
}

class _MyPlanCardState extends State<MyPlanCard> {
  bool collapsed = true;
  final TextEditingController _notesController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Color foreGroundColor = widget.isSelected ? Colors.black : Colors.white;
    var sf = calculateScreenFactors(context);
    return InkWell(
      onTap:
          widget.isSelected ? null : () => widget.onPlanSelected(widget.plan),
      child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? Colors.white
                : (widget.plan.startTime.getMillisecondsSinceEpoch() <=
                        TmiDateTime.now().getMillisecondsSinceEpoch())
                    ? HexColor.fromHex(
                        ConfigProvider.getThemeConfig().pastScheduleCardColor)
                    : HexColor.fromHex(
                        ConfigProvider.getThemeConfig().primaryButtonColor),
            borderRadius: BorderRadius.circular(sf.cf * 32),
            border: Border.all(width: 2, color: Colors.white),
          ),
          child: CustomColumn(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomRow(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CustomText(
                        align: TextAlign.left,
                        text: widget.plan.title,
                        color: foreGroundColor,
                      ),
                    ),
                    widget.readonly
                        ? const SizedBox()
                        : CustomRow(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.plan.startTime
                                      .getMillisecondsSinceEpoch() >
                                  TmiDateTime.now().getMillisecondsSinceEpoch())
                                PopupMenuButton<String>(
                                    icon: Icon(Icons.adaptive.more,
                                        color: foreGroundColor),
                                    onSelected: (val) =>
                                        optionSelected(val, widget.plan.planId),
                                    itemBuilder: (context) => [
                                          "Remove",
                                        ]
                                            .map((e) => PopupMenuItem<String>(
                                                  value: e,
                                                  child: CustomText(text: e),
                                                ))
                                            .toList()),
                              collapsed
                                  ? IconButton(
                                      tooltip: "View notes",
                                      padding: const EdgeInsets.all(0),
                                      onPressed: showNotesTapped,
                                      icon: Icon(
                                        Icons.notes_outlined,
                                        color: foreGroundColor,
                                      ))
                                  : IconButton(
                                      onPressed: hideNotesTapped,
                                      icon: Icon(
                                        Icons.arrow_drop_up,
                                        color: foreGroundColor,
                                      ))
                            ],
                          )
                  ]),
              collapsed
                  ? const SizedBox()
                  : const Padding(
                      padding: EdgeInsets.all(16), child: Divider(height: 0.5)),
              collapsed
                  ? const SizedBox()
                  : CustomColumn(
                      showEmptyImage: false,
                      mainAxisSize: MainAxisSize.min,
                      children: widget.plan.planNotes
                          .map((e) => CustomColumn(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                      text: e.note, color: foreGroundColor),
                                  CustomRow(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      CustomText(
                                          color: foreGroundColor,
                                          size: 8,
                                          text:
                                              "${e.createdOn.getTimeAsString()}, ${e.createdOn.getDateAsString()}"),
                                      IconButton(
                                          onPressed: () =>
                                              deleteNoteTapped(e.planNoteId),
                                          icon: Icon(
                                            Icons.delete,
                                            color: foreGroundColor,
                                          ))
                                    ],
                                  )
                                ],
                              ))
                          .toList(),
                    ),
              collapsed
                  ? const SizedBox()
                  : Center(
                      child: CustomTextField(
                          width: sf.maxComponents <= 2
                              ? null
                              : sf.size.width / 2 - 100 * sf.cf,
                          controller: _notesController,
                          hintText: "Add a note",
                          fillColor: Colors.white,
                          borderColor: foreGroundColor,
                          borderRadius: 32,
                          suffixIcon: IconButton(
                              onPressed: noteAddedTapped,
                              icon: Icon(Icons.send, size: 12 * sf.cf))),
                    ),
            ],
          )),
    );
  }

  void optionSelected(String value, String id) async {
    if (value == "Remove") {
      var proceed = await showShouldProceedDialog(
          "Remove", "Are you sure you want to remove this plan?", context);
      if (!proceed) return;
      var result = await Plan.deletePlan(id, context);
      if (result) {
        widget.onPlanDeleted(id);
      }
    }
  }

  void showNotesTapped() {
    _notesController.text = "";
    collapsed = false;
    setState(() {});
  }

  void hideNotesTapped() {
    _notesController.text = "";
    collapsed = true;
    setState(() {});
  }

  void noteAddedTapped() async {
    var newPlanNote = PlanNote(_notesController.text, TmiDateTime.now(),
        widget.plan.planId, UniqueKey().toString());
    var result = await PlanNote.addPlanNote(newPlanNote, context);
    if (result == null) return;
    _notesController.text = "";
    widget.plan.planNotes.insert(0, result);
    setState(() {});
  }

  deleteNoteTapped(String planNoteId) async {
    var result = await PlanNote.removePlanNote(planNoteId, context);
    if (result) {
      widget.plan.planNotes
          .removeWhere((element) => element.planNoteId == planNoteId);
      setState(() {});
    }
  }
}
