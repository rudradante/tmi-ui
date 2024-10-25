import 'package:flutter/material.dart';

import 'empty_image_widget.dart';

class CustomRow extends StatelessWidget {
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final List<Widget> children;
  const CustomRow(
      {Key? key,
      this.mainAxisAlignment = MainAxisAlignment.start,
      this.crossAxisAlignment = CrossAxisAlignment.center,
      this.mainAxisSize = MainAxisSize.max,
      this.children = const <Widget>[]})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          children.isEmpty ? MainAxisAlignment.center : mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children.isEmpty ? [EmptyImageWidget()] : children,
    );
  }
}
