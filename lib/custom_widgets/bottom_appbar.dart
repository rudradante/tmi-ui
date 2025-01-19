import 'package:flutter/material.dart';
import 'package:tmiui/config/theme.dart';
import 'package:tmiui/screens/plan_dashboard.dart';
import 'package:tmiui/screens/schedule.dart';
import 'package:tmiui/screens/screen_types.dart';

import 'custom_column.dart';
import 'custom_text.dart';

BottomAppBar getTmiBottomAppBar(
    BuildContext context, ScreenType currentScreen) {
  return BottomAppBar(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    height: 60,
    color: Colors.white,
    shape: CircularNotchedRectangle(),
    notchMargin: 5,
    child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        BottomAppBarIconButton("Home", Icons.home,
            () => screenTapped(ScreenType.Dashboard, currentScreen, context)),
        BottomAppBarIconButton("Schedule", Icons.schedule,
            () => screenTapped(ScreenType.Schedule, currentScreen, context)),
        BottomAppBarIconButton("Review", Icons.reviews,
            () => screenTapped(ScreenType.Review, currentScreen, context)),
        BottomAppBarIconButton("My Account", Icons.account_box,
            () => screenTapped(ScreenType.MyAccount, currentScreen, context)),
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
  const BottomAppBarIconButton(this.label, this.icon, this.onTap, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var sf = calculateScreenFactors(context);
    return InkWell(
      onTap: onTap,
      child: CustomColumn(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24 * sf.cf, color: Colors.black),
          CustomText(text: label, align: TextAlign.center, size: 10)
        ],
      ),
    );
  }
}
