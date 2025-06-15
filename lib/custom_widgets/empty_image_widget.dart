import 'package:flutter/material.dart';

import '../config/theme.dart';

class EmptyImageWidget extends StatelessWidget {
  final bool center;
  const EmptyImageWidget({Key? key, this.center = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenFactors sf = calculateScreenFactors(context);
    return center
        ? ClipRRect(
            borderRadius: BorderRadius.circular(64),
            child: Center(
                child: Image.asset("assets/icons/empty.png",
                    width: 128 * sf.cf, height: 128 * sf.cf)))
        : ClipRRect(
            borderRadius: BorderRadius.circular(64),
            child: Image.asset("assets/icons/empty.png",
                width: 128 * sf.cf, height: 128 * sf.cf));
  }
}
