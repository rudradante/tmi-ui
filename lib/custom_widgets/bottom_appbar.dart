import 'package:flutter/material.dart';
import 'package:tmiui/screens/plan_dashboard.dart';
import 'package:tmiui/screens/schedule.dart';
import 'package:tmiui/screens/screen_types.dart';

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
        TextButton.icon(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.transparent)),
            onPressed: () =>
                screenTapped(ScreenType.Dashboard, currentScreen, context),
            icon: const Icon(
              Icons.home,
              color: Colors.black,
            ),
            label: const CustomText(text: "Home")),
        TextButton.icon(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.transparent)),
            onPressed: () =>
                screenTapped(ScreenType.Schedule, currentScreen, context),
            icon: const Icon(
              Icons.schedule,
              color: Colors.black,
            ),
            label: const CustomText(text: "Schedule")),
        TextButton.icon(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.transparent)),
            onPressed: () =>
                screenTapped(ScreenType.Review, currentScreen, context),
            icon: const Icon(
              Icons.reviews,
              color: Colors.black,
            ),
            label: const CustomText(text: "Review")),
        TextButton.icon(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.transparent)),
            onPressed: () =>
                screenTapped(ScreenType.MyAccount, currentScreen, context),
            icon: const Icon(
              Icons.account_box,
              color: Colors.black,
            ),
            label: const CustomText(text: "My Account"))
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
