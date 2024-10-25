import 'package:flutter/material.dart';

import '../config/theme.dart';

class EmptyImageWidget extends StatelessWidget {
  final bool center;
  const EmptyImageWidget({Key? key, this.center = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenFactors sf = calculateScreenFactors(context);
    return center
        ? Center(
            child: Image.asset("assets/icons/empty.png",
                width: 128 * sf.cf, height: 128 * sf.cf))
        : Image.asset("assets/icons/empty.png",
            width: 128 * sf.cf, height: 128 * sf.cf);
  }
}
