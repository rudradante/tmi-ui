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

Map<String, bool> _expandedPlans = {};

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

class _MyPlanCardState extends State<MyPlanCard> with TickerProviderStateMixin {
  final TextEditingController _notesController = TextEditingController();
  bool collapsed = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    collapsed = !_expandedPlans.containsKey(widget.plan.planId);
    final fore = widget.isSelected ? Colors.black : Colors.white;
    final sf = calculateScreenFactors(context);

    return Container(
      key: PageStorageKey('plan-${widget.plan.planId}'),
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

      // Let drags pass through except on the header buttons.
      child: CustomColumn(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER: put the tap only here (not on the whole card)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.isSelected
                ? null
                : () => widget.onPlanSelected(widget.plan),
            child: CustomRow(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomText(
                    align: TextAlign.left,
                    text: widget.plan.title,
                    color: fore,
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
                              icon: Icon(Icons.adaptive.more, color: fore),
                              onSelected: (val) =>
                                  optionSelected(val, widget.plan.planId),
                              itemBuilder: (context) => [
                                PopupMenuItem<String>(
                                  value: "Remove",
                                  child: CustomText(text: "Remove"),
                                ),
                              ],
                            ),
                          IconButton(
                            tooltip: collapsed ? "View notes" : "Hide notes",
                            padding: EdgeInsets.zero,
                            onPressed:
                                collapsed ? showNotesTapped : hideNotesTapped,
                            icon: Icon(
                              collapsed
                                  ? Icons.notes_outlined
                                  : Icons.arrow_drop_up,
                              color: fore,
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),

          // Animate the height change (prevents layout snap that “locks” scroll)
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: collapsed
                ? const SizedBox.shrink()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Divider(height: 0.5),
                      ),

                      // NOTES (non-scrollable, just grows)
                      CustomColumn(
                        showEmptyImage: false,
                        mainAxisSize: MainAxisSize.min,
                        children: widget.plan.planNotes.map((e) {
                          return CustomColumn(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(text: e.note, color: fore),
                              CustomRow(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CustomText(
                                    color: fore,
                                    size: 8,
                                    text:
                                        "${e.createdOn.getTimeAsString()}, ${e.createdOn.getDateAsString()}",
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        deleteNoteTapped(e.planNoteId),
                                    icon: Icon(Icons.delete, color: fore),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }).toList(),
                      ),

                      // INPUT
                      Center(
                        child: CustomTextField(
                          width: sf.maxComponents <= 2
                              ? null
                              : sf.size.width / 2 - 100 * sf.cf,
                          controller: _notesController,
                          hintText: "Add a note",
                          fillColor: Colors.white,
                          borderColor: fore,
                          borderRadius: 32,
                          suffixIcon: IconButton(
                            onPressed: noteAddedTapped,
                            icon: Icon(Icons.send, size: 12 * sf.cf),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void optionSelected(String value, String id) async {
    if (value == "Remove") {
      final proceed = await showShouldProceedDialog(
          "Remove", "Are you sure you want to remove this plan?", context);
      if (!proceed) return;
      final result = await Plan.deletePlan(id, context);
      if (result) widget.onPlanDeleted(id);
    }
  }

  void showNotesTapped() {
    _notesController.text = "";
    _expandedPlans.putIfAbsent(widget.plan.planId, () => false);
    setState(() => collapsed = false);
  }

  void hideNotesTapped() {
    _notesController.text = "";
    _expandedPlans.remove(widget.plan.planId);
    setState(() => collapsed = true);
  }

  Future<void> noteAddedTapped() async {
    final text = _notesController.text.trim();
    if (text.isEmpty) return;

    // (Optional) optimistic insert to avoid rebuild gap
    final tempNote = PlanNote(
        text, TmiDateTime.now(), widget.plan.planId, UniqueKey().toString());
    setState(() {
      widget.plan.planNotes.insert(0, tempNote);
      _notesController.clear();
    });

    final saved = await PlanNote.addPlanNote(tempNote, context);
    if (saved == null) {
      // rollback if failed
      setState(() {
        widget.plan.planNotes.removeWhere((n) => identical(n, tempNote));
      });
      widget.onPlanDeleted(widget.plan.planId);
      return;
    }

    // replace temp with saved (keeps list size same -> minimal layout thrash)
    setState(() {
      final idx =
          widget.plan.planNotes.indexWhere((n) => identical(n, tempNote));
      if (idx != -1) widget.plan.planNotes[idx] = saved;
    });
  }

  Future<void> deleteNoteTapped(String planNoteId) async {
    final ok = await PlanNote.removePlanNote(planNoteId, context);
    if (ok) {
      setState(() {
        widget.plan.planNotes.removeWhere((e) => e.planNoteId == planNoteId);
      });
    }
  }
}
