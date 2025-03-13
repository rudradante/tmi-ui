import 'package:flutter/material.dart';
import 'package:tmiui/custom_widgets/text_button.dart';

import 'custom_dialog.dart';
import 'custom_text.dart';

class MessageDialog extends StatelessWidget {
  final String message;
  final String title;
  const MessageDialog({Key? key, required this.message, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: SelectableText(title),
      content: SelectableText(message),
      actions: [
        CustomTextButton(
            onPressed: () {
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
            text: "OK")
      ],
      actionsAlignment: MainAxisAlignment.center,
    );
  }
}

Future<dynamic> showMessageDialog(
    String title, String message, BuildContext context) async {
  return await showCustomDialog(
      title,
      SizedBox(
          height: 80,
          child: Center(
              child: CustomText(
            text: message,
          ))),
      context,
      forceDialog: true);
}
