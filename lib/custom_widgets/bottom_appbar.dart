import 'package:flutter/material.dart';
import 'package:tmiui/config/config_provider.dart';
import 'package:tmiui/config/theme.dart';
import 'package:tmiui/screens/plan_dashboard.dart';
import 'package:tmiui/screens/schedule.dart';
import 'package:tmiui/screens/screen_types.dart';

import '../extensions/color.dart';
import 'custom_column.dart';
import 'custom_text.dart';

BottomAppBar getTmiBottomAppBar(BuildContext context, ScreenType currentScreen,
    {Color? bgColor, Color? fgColor}) {
  var theme = ConfigProvider.getThemeConfig();

  var textColor = fgColor == null ? Colors.black : Colors.white;
  fgColor = fgColor ?? HexColor.fromHex(theme.primaryButtonColor);
  return BottomAppBar(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    height: 60,
    color: bgColor ?? Colors.white,
    shape: CircularNotchedRectangle(),
    notchMargin: 5,
    child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        BottomAppBarIconButton(
            "My Plans",
            Icons.assignment_outlined,
            () => screenTapped(ScreenType.Dashboard, currentScreen, context),
            fgColor,
            textColor),
        BottomAppBarIconButton(
            "My Schedule",
            Icons.schedule,
            () => screenTapped(ScreenType.Schedule, currentScreen, context),
            fgColor,
            textColor),
        SizedBox(
          width: 16,
        ),
        BottomAppBarIconButton(
            "My Review",
            Icons.assessment_outlined,
            () => screenTapped(ScreenType.Review, currentScreen, context),
            fgColor,
            textColor),
        BottomAppBarIconButton(
            "My Account",
            Icons.account_box_outlined,
            () => screenTapped(ScreenType.MyAccount, currentScreen, context),
            fgColor,
            textColor),
      ],
    ),
  );
}

void screenTapped(
    ScreenType selectedScreen, ScreenType currentScreen, BuildContext context) {
  if (selectedScreen == currentScreen) return;
  switch (selectedScreen) {
    case ScreenType.Dashboard:
      PlanDashboardRoute.push(context);
      break;

    case ScreenType.Schedule:
      SchedulePlansRoute.push(context, [], (p0) {});
      break;

    default:
      return;
  }
}

class BottomAppBarIconButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final void Function() onTap;
  final Color color;
  final Color textColor;
  const BottomAppBarIconButton(
      this.label, this.icon, this.onTap, this.color, this.textColor,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var sf = calculateScreenFactors(context);
    return InkWell(
      onTap: onTap,
      child: CustomColumn(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24 * sf.cf, color: color),
          CustomText(
            text: label,
            align: TextAlign.center,
            size: 10,
            color: textColor,
          )
        ],
      ),
    );
  }
}
