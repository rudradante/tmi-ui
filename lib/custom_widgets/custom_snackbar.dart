import 'package:flutter/material.dart';
import 'package:tmiui/custom_widgets/custom_text.dart';

void showSnackBarMessage(BuildContext context, String message) {
  var snackBar = SnackBar(
    content: CustomText(
      text: message,
      color: Colors.white,
    ),
    showCloseIcon: true,
    duration: const Duration(hours: 1),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
