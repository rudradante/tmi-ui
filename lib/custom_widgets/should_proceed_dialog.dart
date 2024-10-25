import 'package:flutter/material.dart';
import 'package:tmiui/config/config_provider.dart';

import '../extensions/color.dart';
import 'custom_dialog.dart';
import 'custom_flat_button.dart';
import 'custom_text.dart';

class ShouldProceedDialog extends StatelessWidget {
  final String title;
  final String message;
  final String proceedText;
  final String declineText;
  final bool isFocusOnProceed;
  const ShouldProceedDialog(
      {Key? key,
      required this.title,
      required this.message,
      required this.isFocusOnProceed,
      required this.proceedText,
      required this.declineText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = ConfigProvider.getThemeConfig();
    return CustomDialog(
        title: title,
        content: CustomText(text: message, align: TextAlign.left),
        actions: [
          CustomFlatButton(
            onTap: () => Navigator.pop(context, true),
            text: proceedText,
            isOutlined: !isFocusOnProceed,
            color: HexColor.fromHex(theme.primaryThemeForegroundColor),
          ),
          CustomFlatButton(
            onTap: () => Navigator.pop(context, false),
            text: declineText,
            isOutlined: isFocusOnProceed,
            color: HexColor.fromHex(theme.primaryThemeForegroundColor),
          ),
        ]);
  }
}

Future<bool> showShouldProceedDialog(
    String title, String message, BuildContext context,
    {bool isFocusOnProceed = true,
    String proceedText = "Yes",
    String declineText = "No"}) async {
  return await showDialog<bool?>(
          context: context,
          builder: (context) => ShouldProceedDialog(
                title: title,
                message: message,
                isFocusOnProceed: isFocusOnProceed,
                proceedText: proceedText,
                declineText: declineText,
              )) ==
      true;
}
