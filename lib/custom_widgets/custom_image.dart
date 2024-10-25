import 'package:flutter/material.dart';
import 'package:tmiui/config/config_provider.dart';

import '../config/theme.dart';
import '../extensions/color.dart';
import 'custom_text.dart';

class CustomImage extends StatelessWidget {
  final ImageProvider image;
  final double width, height;
  final double clipRadius;
  final bool forceBorder;
  final String? placeholderText;
  const CustomImage(
      {Key? key,
      required this.image,
      required this.height,
      required this.width,
      this.placeholderText,
      this.clipRadius = 0,
      this.forceBorder = false})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    ScreenFactors sf = calculateScreenFactors(context);
    var theme = ConfigProvider.getThemeConfig();
    return ClipRRect(
        borderRadius: BorderRadius.circular(clipRadius * sf.cf),
        child: Container(
          height: height * sf.cf,
          width: width * sf.cf,
          decoration: BoxDecoration(
              color: forceBorder
                  ? HexColor.fromHex(theme.scaffoldBackgroundColor)
                  : Colors.transparent,
              borderRadius:
                  BorderRadius.all(Radius.circular(clipRadius * sf.cf)),
              border: Border.all(
                  color: forceBorder
                      ? const Color(0xFFC4C4C4)
                      : Colors.transparent)),
          child: FadeInImage(
              fit: BoxFit.fill,
              height: height * sf.cf,
              width: width * sf.cf,
              imageErrorBuilder: (context, error, stackTrace) =>
                  placeholderText == null
                      ? Icon(Icons.broken_image,
                          color: Colors.grey, size: height * sf.cf)
                      : FittedBox(
                          child: Padding(
                          padding: EdgeInsets.all(height / 4),
                          child: Center(
                              child: CustomText(
                                  size: 32 * sf.cf,
                                  text: placeholderText ?? "",
                                  color: HexColor.fromHex(
                                      theme.appBarBackgroundColor))),
                        )),
              placeholderErrorBuilder: (context, error, stackTrace) => Icon(
                  Icons.broken_image,
                  color: const Color(0xFFF3F5F9),
                  size: height * sf.cf),
              placeholder: const AssetImage('assets/gif/shimmer.gif'),
              image: image),
        ));
  }
}
