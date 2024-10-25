import 'package:flutter/material.dart';
import 'package:tmiui/config/config_provider.dart';
import 'package:tmiui/extensions/color.dart';

class CustomRangeSlider extends StatefulWidget {
  final double max, min;
  final RangeValues? currentRange;
  final void Function(RangeValues) onSlideEnd;
  const CustomRangeSlider(
      {Key? key,
      this.min = 0,
      this.max = 0,
      required this.onSlideEnd,
      this.currentRange})
      : super(key: key);

  @override
  State<CustomRangeSlider> createState() => _CustomRangeSliderState();
}

class _CustomRangeSliderState extends State<CustomRangeSlider> {
  double min = 0, max = 0;
  RangeValues rangeValues = const RangeValues(0, 100);
  @override
  void initState() {
    super.initState();
    min = widget.min;
    max = widget.max;
    rangeValues = widget.currentRange ?? RangeValues(min, max);
  }

  @override
  Widget build(BuildContext context) {
    var theme = ConfigProvider.getThemeConfig();
    return RangeSlider(
      activeColor: HexColor.fromHex(theme.primaryThemeForegroundColor),
      values: rangeValues,
      max: max,
      min: min,
      divisions: (max - min).toInt(),
      labels: RangeLabels(
        rangeValues.start.round().toString(),
        rangeValues.end.round().toString(),
      ),
      onChanged: (RangeValues values) {
        setState(() {
          rangeValues = values;
        });
      },
      onChangeEnd: (rv) {
        setState(() {});
        widget.onSlideEnd(rv);
      },
    );
  }
}
