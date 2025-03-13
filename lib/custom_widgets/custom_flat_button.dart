import 'package:flutter/material.dart';
import 'package:tmiui/config/config_provider.dart';

import '../config/theme.dart';
import 'custom_text.dart';

class CustomFlatButton extends StatelessWidget {
  final Function()? onTap;
  final String text;
  final Color color;
  final bool isOutlined;
  final bool elevated;
  final Color? outlineColor;
  const CustomFlatButton(
      {Key? key,
      this.onTap,
      required this.text,
      this.isOutlined = false,
      required this.color,
      this.elevated = false,
      this.outlineColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenFactors sf = calculateScreenFactors(context);
    var theme = ConfigProvider.getThemeConfig();
    var container = Container(
      margin: const EdgeInsets.all(2),
      padding: EdgeInsets.only(
          left: 16 * sf.cf,
          right: 16 * sf.cf,
          top: (sf.maxComponents < 2 ? 8 : 4) * sf.cf,
          bottom: (sf.maxComponents < 2 ? 8 : 4) * sf.cf),
      decoration: BoxDecoration(
          boxShadow: elevated
              ? const [
                  BoxShadow(
                      color: Colors.blueGrey, blurRadius: 12, spreadRadius: 6)
                ]
              : null,
          color: isOutlined ? Colors.transparent : color,
          border: (!isOutlined && outlineColor == null)
              ? null
              : Border.all(
                  width: outlineColor == null ? 0.5 : 2,
                  color: outlineColor ?? color),
          borderRadius: BorderRadius.circular((theme.primaryTextSize) * sf.cf)),
      child: CustomText(
          text: text,
          color: isOutlined ? color : Colors.white,
          size: (sf.maxComponents < 2 ? 12 : 10) * sf.cf),
    );
    return onTap == null ? container : InkWell(onTap: onTap, child: container);
  }
}
