import 'package:flutter/material.dart';
import 'package:tmiui/custom_widgets/text_field.dart';
import '../config/config_provider.dart';
import '../config/theme.dart';
import '../extensions/color.dart';
import 'custom_column.dart';
import 'custom_dialog.dart';
import 'custom_flat_button.dart';

class CustomFormData {
  String? errorText;
  String initialText;
  bool toggleView, hiddenText;
  bool readonly;
  double? width;
  bool isMandatory;
  Function(String)? onEditing;
  CustomFormData(
      {required this.initialText,
      this.errorText,
      this.toggleView = false,
      this.hiddenText = false,
      this.width,
      this.readonly = false,
      this.isMandatory = true,
      this.onEditing});
}

class CustomForm extends StatefulWidget {
  final Map<String, CustomFormData> formData;
  final String title;
  final String submitText;
  final bool isDialog;
  final Function(Map<String, String>) onSubmit;
  final double? elevation;
  const CustomForm(
      {Key? key,
      required this.formData,
      required this.title,
      required this.submitText,
      required this.onSubmit,
      this.elevation,
      this.isDialog = true})
      : super(key: key);

  @override
  _CustomFormState createState() => _CustomFormState();
}

class _CustomFormState extends State<CustomForm> {
  Map<String, TextEditingController> controllers = {};
  @override
  void initState() {
    super.initState();
    widget.formData.keys.forEach((key) {
      controllers.putIfAbsent(key,
          () => TextEditingController(text: widget.formData[key]?.initialText));
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenFactors sf = calculateScreenFactors(context);

    var theme = ConfigProvider.getThemeConfig();
    List<Widget> widgets = [const Padding(padding: EdgeInsets.all(8))];
    widgets.addAll(
        controllers.keys.map((key) => buildFormInput(key, sf)).toList());
    widgets.add(Center(
        child: CustomFlatButton(
            color: HexColor.fromHex(theme.primaryThemeForegroundColor),
            onTap: validateInputBeforeSubmit,
            text: widget.submitText)));
    return widget.isDialog
        ? CustomDialog(
            title: widget.title,
            content: CustomColumn(
              mainAxisSize: MainAxisSize.min,
              children: widgets,
            ),
          )
        : CustomColumn(mainAxisSize: MainAxisSize.min, children: widgets);
  }

  Widget buildFormInput(String key, ScreenFactors sf) {
    return CustomColumn(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: CustomTextField(
            readOnly: widget.formData[key]?.readonly ?? false,
            errorText: widget.formData[key]?.errorText,
            toggleView: widget.formData[key]?.toggleView ?? false,
            hiddenText: (widget.formData[key]?.toggleView ?? false)
                ? true
                : widget.formData[key]?.hiddenText ?? false,
            controller: controllers[key],
            label: key,
            width: widget.formData[key]?.width ??
                (ThemeConfig.referenceScreenWidth - 20) * sf.cf,
          ),
        ),
        const Padding(padding: EdgeInsets.all(4)),
      ],
    );
  }

  validateInputBeforeSubmit() {
    var errors = false;
    for (var key in controllers.keys) {
      if (widget.formData[key]!.isMandatory &&
          controllers[key]!.text.trim().isEmpty) {
        widget.formData[key]!.errorText = "Please fill this field";
        errors = true;
      }
    }
    if (errors) {
      setState(() {});
    } else {
      widget.onSubmit(controllers
          .map((key, value) => MapEntry<String, String>(key, value.text)));
    }
  }
}
