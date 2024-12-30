// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

import '../config/theme.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? errorText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final double? width;
  final bool hiddenText;
  final bool toggleView;
  final bool readOnly;
  final Function(String)? onEditing;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool underlinedBorder;
  final Color? borderColor, textColor, fillColor;
  final void Function()? onTap;
  final void Function(String?)? onSubmitted;
  final double borderRadius;
  const CustomTextField(
      {Key? key,
      required this.controller,
      this.label,
      this.errorText,
      this.hintText,
      this.prefixIcon,
      this.suffixIcon,
      this.maxLines = 1,
      this.width,
      this.onEditing,
      this.hiddenText = false,
      this.toggleView = false,
      this.focusNode,
      this.underlinedBorder = false,
      this.readOnly = false,
      this.onSubmitted,
      this.onTap,
      this.borderColor,
      this.fillColor,
      this.textColor,
      this.borderRadius = 8})
      : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool hiddenText = false;

  @override
  void initState() {
    super.initState();
    hiddenText = widget.toggleView ? true : widget.hiddenText;
  }

  @override
  Widget build(BuildContext context) {
    ScreenFactors sf = calculateScreenFactors(context);
    return Container(
        margin: EdgeInsets.only(
            bottom: (widget.errorText == null ? 2 : (sf.textSize - 6) * sf.cf)),
        width: widget.width ?? 272 * sf.cf,
        child: TextField(
          readOnly: widget.readOnly,
          onSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          focusNode: widget.focusNode,
          onChanged: widget.onEditing,
          obscureText: hiddenText,
          controller: widget.controller,
          style: TextStyle(
              fontSize: sf.textSize,
              color: widget.readOnly ? Colors.grey : widget.textColor),
          maxLines: widget.maxLines,
          decoration: InputDecoration(
              isDense: true,
              labelText: widget.label,
              labelStyle: TextStyle(
                  fontSize: sf.textSize,
                  color: widget.readOnly ? Colors.grey : widget.textColor),
              errorStyle: TextStyle(fontSize: sf.textSize - 6),
              hintStyle: TextStyle(fontSize: sf.textSize),
              errorText: widget.errorText,
              hintText: widget.hintText,
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.toggleView
                  ? buildToggleButton(sf)
                  : widget.suffixIcon ?? SizedBox(height: sf.textSize + 4),
              border: widget.underlinedBorder
                  ? const UnderlineInputBorder()
                  : OutlineInputBorder(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      borderSide: widget.readOnly
                          ? const BorderSide(color: Colors.grey)
                          : widget.borderColor == null
                              ? const BorderSide()
                              : BorderSide(color: widget.borderColor!)),
              contentPadding: const EdgeInsets.all(8),
              filled: widget.fillColor != null,
              fillColor: widget.fillColor,
              enabledBorder: widget.underlinedBorder
                  ? const UnderlineInputBorder()
                  : OutlineInputBorder(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      borderSide: widget.readOnly
                          ? const BorderSide(color: Colors.grey)
                          : widget.borderColor == null
                              ? const BorderSide()
                              : BorderSide(color: widget.borderColor!)),
              disabledBorder: widget.underlinedBorder
                  ? const UnderlineInputBorder()
                  : OutlineInputBorder(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      borderSide: widget.readOnly
                          ? const BorderSide(color: Colors.grey)
                          : widget.borderColor == null
                              ? const BorderSide()
                              : BorderSide(color: widget.borderColor!)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: widget.readOnly
                      ? const BorderSide(color: Colors.grey)
                      : widget.borderColor == null
                          ? const BorderSide()
                          : BorderSide(color: widget.borderColor!))),
        ));
  }

  Widget buildToggleButton(ScreenFactors sf) {
    return IconButton(
        onPressed: () => setState(() {
              hiddenText = !hiddenText;
            }),
        icon: ImageIcon(
            AssetImage('assets/icons/${!hiddenText ? 'hide.png' : 'show.png'}'),
            size: 18 * sf.cf));
  }
}
