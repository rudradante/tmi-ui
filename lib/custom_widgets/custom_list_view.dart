import 'package:flutter/material.dart';

import '../config/theme.dart';
import 'empty_image_widget.dart';

class CustomListView extends StatelessWidget {
  const CustomListView(
      {Key? key,
      required this.itemBuilder,
      required this.itemCount,
      this.scrollDirection = Axis.vertical,
      this.shrinkWrap = true,
      this.reverse = false,
      this.controller})
      : super(key: key);
  final Widget Function(BuildContext, int) itemBuilder;
  final int itemCount;
  final bool shrinkWrap, reverse;
  final Axis scrollDirection;
  final ScrollController? controller;
  @override
  Widget build(BuildContext context) {
    ScreenFactors sf = calculateScreenFactors(context);
    return Container(
      alignment: Alignment.topLeft,
      constraints:
          BoxConstraints(maxWidth: sf.size.width, maxHeight: sf.size.height),
      child: itemCount == 0
          ? const Center(child: EmptyImageWidget())
          : ListView.builder(
              reverse: reverse,
              controller: controller,
              itemCount: itemCount,
              itemBuilder: itemBuilder,
              scrollDirection: scrollDirection),
    );
  }
}

class CustomStaticListView extends StatelessWidget {
  final List<Widget> children;
  final Axis scrollDirection;
  final bool shrinkWrap, reverse;
  final ScrollController? controller;
  const CustomStaticListView(
      {Key? key,
      required this.children,
      this.scrollDirection = Axis.vertical,
      this.shrinkWrap = true,
      this.reverse = false,
      this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenFactors sf = calculateScreenFactors(context);
    return Container(
      constraints:
          BoxConstraints(maxWidth: sf.size.width, maxHeight: sf.size.height),
      child: children.isEmpty
          ? const EmptyImageWidget()
          : ListView(
              controller: controller,
              reverse: reverse,
              scrollDirection: scrollDirection,
              children: children,
            ),
    );
  }
}
