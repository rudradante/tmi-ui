import 'package:flutter/material.dart';
import 'package:tmiui/config/config_provider.dart';
import 'package:tmiui/extensions/color.dart';

import 'custom_column.dart';
import 'custom_row.dart';
import 'custom_text.dart';

class GroupingContainer extends StatelessWidget {
  final double? width, height;
  final String label;
  final String? subtitle;
  final Widget? leading;
  final Widget child;
  final bool elevated;
  const GroupingContainer(
      {Key? key,
      required this.label,
      required this.child,
      this.width,
      this.leading,
      this.subtitle,
      this.height,
      this.elevated = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = ConfigProvider.getThemeConfig();
    return Container(
      width: width,
      height: height,
      padding: elevated ? const EdgeInsets.all(20) : const EdgeInsets.all(8),
      margin: elevated ? const EdgeInsets.all(16) : const EdgeInsets.all(8),
      decoration: elevated
          ? BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                  BoxShadow(
                      color: Colors.blueGrey, blurRadius: 12, spreadRadius: 6)
                ])
          : BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                  width: 0.5,
                  color: HexColor.fromHex(theme.inactiveTextColor))),
      child: CustomColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: height == null ? MainAxisSize.min : MainAxisSize.max,
        children: [
          CustomRow(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  flex: 1,
                  child: CustomColumn(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: CustomText(
                              text: label,
                              size: elevated
                                  ? 16
                                  : theme.primaryTextSize.toDouble(),
                              align: TextAlign.left,
                              bold: true,
                            )),
                        subtitle == null
                            ? const SizedBox()
                            : CustomText(
                                text: subtitle ?? "",
                                size: 12,
                                color:
                                    HexColor.fromHex(theme.inactiveTextColor),
                                align: TextAlign.left,
                              )
                      ])),
              leading ?? const SizedBox()
            ],
          ),
          Padding(padding: EdgeInsets.all(elevated ? 16 : 8)),
          height == null
              ? child
              : Expanded(
                  child: child,
                )
        ],
      ),
    );
  }
}
