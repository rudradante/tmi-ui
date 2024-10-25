import 'package:flutter/material.dart';

import 'empty_image_widget.dart';

class CustomColumn extends StatelessWidget {
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final List<Widget> children;
  final bool showEmptyImage;
  const CustomColumn(
      {Key? key,
      this.mainAxisAlignment = MainAxisAlignment.start,
      this.crossAxisAlignment = CrossAxisAlignment.center,
      this.mainAxisSize = MainAxisSize.max,
      this.children = const <Widget>[],
      this.showEmptyImage = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment:
          children.isEmpty ? MainAxisAlignment.center : mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children.isEmpty
          ? [showEmptyImage ? const EmptyImageWidget() : const SizedBox()]
          : children,
    );
  }
}
