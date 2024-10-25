import 'package:flutter/material.dart';

import '../config/theme.dart';
import 'custom_column.dart';
import 'custom_image.dart';
import 'custom_row.dart';

List<Color> colors = [
  const Color.fromARGB(255, 251, 235, 235),
  const Color.fromARGB(255, 252, 244, 251)
];
int colorIdx = 0;

class CustomListTile extends StatelessWidget {
  final Function()? onTap;
  final String? placeholderText;
  final ImageProvider image;
  final Widget title;
  final Widget? subtitle;
  const CustomListTile(
      {Key? key,
      required this.image,
      required this.title,
      this.subtitle,
      this.placeholderText,
      this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenFactors sf = calculateScreenFactors(context);
    return Padding(
        padding: const EdgeInsets.all(8),
        child: CustomRow(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onTap,
              child: CustomImage(
                forceBorder: true,
                placeholderText: placeholderText,
                image: image,
                height: 32 * sf.cf,
                width: 32 * sf.cf,
                clipRadius: 32 * sf.cf,
              ),
            ),
            Expanded(
                child: Container(
                    margin: const EdgeInsets.all(0),
                    padding: EdgeInsets.only(
                        left: 4 * sf.cf,
                        right: 4 * sf.cf,
                        top: 2 * sf.cf,
                        bottom: 2 * sf.cf),
                    child: CustomColumn(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        title,
                        subtitle ?? const Padding(padding: EdgeInsets.zero)
                      ],
                    )))
          ],
        ));
  }
}
