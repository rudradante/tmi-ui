import 'package:flutter/material.dart';
import 'package:tmiui/config/config_provider.dart';

class ThemeConfig {
  String primaryThemeBackgroundColor = '1B89A1';
  String primaryThemeForegroundColor = 'F2B866';
  String primaryThemeTextColor = 'FFFFFF';
  String contentTextColor = '8A000000';
  String appBarBackgroundColor = 'FFFFFF';
  String appBarForegroundColor = 'FFFFFF';
  String scaffoldBackgroundColor = 'FFFFFF';
  String primaryButtonColor = '7A80A6';
  String inactiveTextColor = 'E5E5E5';
  int primaryTextSize = 14;
  int secondaryTextSize = 12;
  String primaryScheduleCardColor = '20B2AA';
  String secondaryScheduleCardColor = '008B8B';
  String pastScheduleCardColor = '778899';
  static double referenceScreenWidth = 360;
  static double referenceScreenHeight = 640;

  ThemeConfig(
      this.primaryThemeBackgroundColor,
      this.primaryThemeForegroundColor,
      this.primaryThemeTextColor,
      this.appBarBackgroundColor,
      this.appBarForegroundColor,
      this.scaffoldBackgroundColor,
      this.primaryButtonColor,
      this.primaryTextSize,
      this.secondaryTextSize,
      this.contentTextColor,
      this.inactiveTextColor,
      this.primaryScheduleCardColor,
      this.secondaryScheduleCardColor,
      this.pastScheduleCardColor);

  static ThemeConfig fromJson(Map<String, dynamic> json) {
    return ThemeConfig(
        json['primaryThemeBackgroundColor'],
        json['primaryThemeForegroundColor'],
        json['primaryThemeTextColor'],
        json['appBarBackgroundColor'],
        json['appBarForegroundColor'],
        json['scaffoldBackgroundColor'],
        json['primaryButtonColor'],
        int.parse(json['primaryTextSize'].toString()),
        int.parse(json['secondaryTextSize'].toString()),
        json['contentTextColor'],
        json['inactiveTextColor'],
        json['primaryScheduleCardColor'],
        json['secondaryScheduleCardColor'],
        json['pastScheduleCardColor']);
  }
}

class ScreenFactors {
  Size size;
  double cf;
  double textSize;
  int maxComponents;
  ScreenFactors(this.size, this.cf, this.textSize, this.maxComponents);
  factory ScreenFactors.empty() {
    return ScreenFactors(
        Size(ThemeConfig.referenceScreenWidth,
            ThemeConfig.referenceScreenHeight),
        1,
        ConfigProvider.getThemeConfig().primaryTextSize.toDouble(),
        1);
  }
}

ScreenFactors calculateScreenFactors(BuildContext context) {
  Size size = MediaQuery.of(context).size;
  double cf = 1;
  double width = size.width;
  cf = width / ThemeConfig.referenceScreenWidth;
  int maxComponents = (width <= 640
      ? 1
      : width <= 1008
          ? 2
          : width <= 1920
              ? 3
              : 4);
  cf /= (width / maxComponents) / ThemeConfig.referenceScreenWidth;
  if (cf >= 1.2) cf = 1.2;
  double textSize =
      ConfigProvider.getThemeConfig().primaryTextSize.toDouble() * cf / 1.2;
  if (textSize > 16) textSize = 16;
  return ScreenFactors(size, cf, textSize, maxComponents);
}
