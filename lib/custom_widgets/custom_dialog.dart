import 'package:flutter/material.dart';
import 'package:tmiui/config/config_provider.dart';

import '../config/theme.dart';
import '../extensions/color.dart';
import 'custom_column.dart';
import 'custom_row.dart';
import 'custom_scaffold.dart';
import 'custom_text.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;
  final EdgeInsets contentPadding;
  const CustomDialog(
      {Key? key,
      required this.title,
      required this.content,
      this.actions = const [],
      this.contentPadding = const EdgeInsets.all(8)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenFactors sf = calculateScreenFactors(context);
    var theme = ConfigProvider.getThemeConfig();
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      contentPadding: contentPadding,
      title: Container(
        padding: title.isEmpty
            ? EdgeInsets.zero
            : EdgeInsets.only(
                left: 8 * sf.cf, top: 4 * sf.cf, bottom: 4 * sf.cf),
        color: title.isEmpty
            ? Colors.transparent
            : HexColor.fromHex(theme.appBarBackgroundColor),
        child: title.isEmpty
            ? null
            : CustomColumn(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomRow(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: CustomText(
                        text: title,
                        size: 16,
                        bold: false,
                        color: HexColor.fromHex(theme.appBarForegroundColor),
                        align: TextAlign.left,
                      )),
                      IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close,
                            size: 18 * sf.cf,
                            color:
                                HexColor.fromHex(theme.appBarForegroundColor),
                          ))
                    ],
                  ),
                ],
              ),
      ),
      content: SingleChildScrollView(
          child: Container(
        constraints: BoxConstraints(maxWidth: sf.size.width),
        child: content,
      )),
      actions: actions,
    );
  }
}

Future<dynamic> showCustomDialog(
    String title, Widget content, BuildContext context,
    {List<Widget> actions = const [],
    bool forceDialog = false,
    EdgeInsets contentPadding = const EdgeInsets.all(8)}) async {
  ScreenFactors sf = calculateScreenFactors(context);
  return sf.maxComponents < 2 && !forceDialog
      ? await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CustomScaffold(
                  title: title,
                  scaffoldBackgroundColor: Colors.white,
                  centerWidget: content)))
      : await showDialog(
          barrierDismissible: title.isEmpty,
          context: context,
          builder: (context) => CustomDialog(
              title: title,
              content: content,
              actions: actions,
              contentPadding: contentPadding));
}
