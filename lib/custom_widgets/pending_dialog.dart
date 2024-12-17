import 'package:flutter/material.dart';

import '../config/theme.dart';
import 'custom_text.dart';

class PendingDialog extends StatefulWidget {
  final String title;
  final bool image;
  const PendingDialog({Key? key, required this.title, this.image = true})
      : super(key: key);
  @override
  PendingDialogState createState() => PendingDialogState();
}

class PendingDialogState extends State<PendingDialog> {
  @override
  Widget build(BuildContext context) {
    ScreenFactors sf = calculateScreenFactors(context);
    return widget.image
        ? Center(
            child: Image.asset(
              'assets/icons/loading.gif',
              height: sf.cf * 64,
              width: sf.cf * 64,
            ),
          )
        : AlertDialog(
            title: CustomText(text: widget.title),
            content: Image.asset(
              'assets/icons/loading.gif',
              height: sf.cf * 64,
              width: sf.cf * 64,
            ));
  }
}
