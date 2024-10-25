// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

import '../config/theme.dart';
import 'custom_text.dart';

class CustomTextButton extends StatefulWidget {
  final void Function() onPressed;
  final String text;
  const CustomTextButton(
      {Key? key, required this.onPressed, required this.text})
      : super(key: key);

  @override
  _CustomTextButtonState createState() => _CustomTextButtonState();
}

class _CustomTextButtonState extends State<CustomTextButton> {
  @override
  Widget build(BuildContext context) {
    ScreenFactors sf = calculateScreenFactors(context);
    return TextButton(
      style: ButtonStyle(
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(sf.cf * 24)))),
      onPressed: widget.onPressed,
      child: Padding(
        padding: EdgeInsets.only(
            left: 56 * sf.cf,
            right: 56 * sf.cf,
            top: 6 * sf.cf,
            bottom: 6 * sf.cf),
        child: CustomText(
          text: widget.text,
          color: Colors.white,
        ),
      ),
    );
  }
}
