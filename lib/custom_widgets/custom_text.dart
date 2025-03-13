import 'package:flutter/material.dart';
import 'package:tmiui/config/config_provider.dart';
import 'package:tmiui/extensions/color.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/theme.dart';

class CustomText extends StatelessWidget {
  final String text;
  final Color? color;
  final double? size;
  final bool bold;
  final TextAlign align;
  final bool underlined;
  final bool selectable;
  final int? maxLines;
  final bool highlight;
  final bool wrap;
  final FontWeight? fontWeight;
  final TextStyle? textStyle;
  const CustomText(
      {Key? key,
      required this.text,
      this.color,
      this.size,
      this.bold = false,
      this.underlined = false,
      this.align = TextAlign.center,
      this.selectable = false,
      this.wrap = true,
      this.highlight = false,
      this.fontWeight,
      this.maxLines,
      this.textStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenFactors sf = calculateScreenFactors(context);
    var theme = ConfigProvider.getThemeConfig();
    return selectable
        ? SelectableText(text,
            textAlign: align,
            style: textStyle ??
                GoogleFonts.poppins(
                    textStyle: TextStyle(
                        decorationColor:
                            color ?? HexColor.fromHex(theme.contentTextColor),
                        decoration:
                            underlined ? TextDecoration.underline : null,
                        fontWeight: fontWeight ??
                            (bold ? FontWeight.bold : FontWeight.normal),
                        fontSize: (size == null
                            ? sf.textSize
                            : size ?? theme.primaryTextSize * sf.cf),
                        color:
                            color ?? HexColor.fromHex(theme.contentTextColor))))
        : highlight
            ? Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4 * sf.cf),
                    border: Border.all(
                        color: HexColor.fromHex(
                            theme.primaryThemeForegroundColor))),
                padding: EdgeInsets.all(4 * sf.cf),
                child: buildTextWidget(sf),
              )
            : buildTextWidget(sf);
  }

  Widget buildTextWidget(ScreenFactors sf) {
    var theme = ConfigProvider.getThemeConfig();
    return Text(text,
        maxLines: maxLines,
        softWrap: wrap,
        textAlign: align,
        //overflow: TextOverflow.ellipsis,
        style: textStyle ??
            GoogleFonts.poppins(
                textStyle: TextStyle(
                    decorationColor:
                        color ?? HexColor.fromHex(theme.contentTextColor),
                    decoration: underlined ? TextDecoration.underline : null,
                    fontWeight: fontWeight ??
                        (bold ? FontWeight.bold : FontWeight.normal),
                    fontSize: (size == null
                        ? sf.textSize
                        : size ?? theme.primaryTextSize * sf.cf),
                    color: color ?? HexColor.fromHex(theme.contentTextColor))));
  }
}
