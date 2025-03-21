import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmiui/config/config_provider.dart';
import 'package:tmiui/config/theme.dart';
import 'package:tmiui/extensions/color.dart';

import 'custom_column.dart';
import 'custom_dialog.dart';
import 'custom_row.dart';
import 'custom_text.dart';

double navBarHeight = 0;
bool _heightNoted = false;
bool _heightNoting = false;

class CustomScaffold extends StatefulWidget {
  static double bodyHeight = ThemeConfig.referenceScreenHeight;
  static var theme = ConfigProvider.getThemeConfig();
  final Widget? sideMenu,
      navBarWidget,
      centerWidget,
      metaWidget,
      floatingActionButton;
  final Widget? leadingAppbarWidget;
  final double appBarTitleSize;
  final Icon sideMenuIcon, metaWidgetIcon;
  final List<Widget> actions;
  final String sideMenuOptionTitle, metaWidgetOptionTitle, title;
  final Function()? onMetaWidgetTapped;
  final Color scaffoldBackgroundColor;
  final Color? appBarBackgroundColor;
  final bool showBackButton;
  final BottomAppBar? bottomAppBar;

  const CustomScaffold(
      {Key? key,
      this.navBarWidget,
      this.sideMenu,
      this.leadingAppbarWidget,
      required this.title,
      required this.scaffoldBackgroundColor,
      this.actions = const [],
      this.showBackButton = true,
      this.centerWidget,
      this.metaWidget,
      this.floatingActionButton,
      this.onMetaWidgetTapped,
      this.appBarTitleSize = 16,
      this.sideMenuOptionTitle = "Options",
      this.metaWidgetOptionTitle = "Reports",
      this.metaWidgetIcon = const Icon(Icons.poll_outlined),
      this.sideMenuIcon = const Icon(
        Icons.menu,
      ),
      this.appBarBackgroundColor,
      this.bottomAppBar})
      : super(key: key);
  @override
  State<CustomScaffold> createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<CustomScaffold> {
  ValueNotifier<bool> isSideMenuOpened = ValueNotifier<bool>(false);
  @override
  Widget build(BuildContext context) {
    ScreenFactors sf = calculateScreenFactors(context);
    List<Widget> actions = [];
    actions.addAll(widget.actions);
    if (sf.maxComponents < 2 && widget.sideMenu != null) {
      actions.add(
          IconButton(onPressed: openViewSideMenu, icon: widget.sideMenuIcon));
    }
    if (sf.maxComponents < 3 && widget.metaWidget != null) {
      actions.add(IconButton(
          onPressed: widget.onMetaWidgetTapped, icon: widget.metaWidgetIcon));
    }
    var theme = ConfigProvider.getThemeConfig();
    AppBar appBar = AppBar(
      backgroundColor:
          widget.appBarBackgroundColor ?? widget.scaffoldBackgroundColor,
      elevation: 0,
      actions: actions,
      title: CustomText(
          textStyle: GoogleFonts.seaweedScript(
              textStyle: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: (widget.appBarTitleSize),
                  color: HexColor.fromHex(theme.appBarForegroundColor))),
          text: widget.title,
          color: HexColor.fromHex(theme.appBarForegroundColor),
          bold: false,
          size: widget.appBarTitleSize),
      centerTitle: false,
      leading: widget.showBackButton
          ? IconButton(
              onPressed: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back,
                color: HexColor.fromHex(theme.appBarForegroundColor),
              ))
          : widget.leadingAppbarWidget,
    );
    CustomScaffold.bodyHeight = sf.size.height -
        appBar.preferredSize.height -
        (widget.bottomAppBar == null ? 0 : kBottomNavigationBarHeight) -
        96;
    return Scaffold(
      extendBody: true,
      appBar: appBar,
      backgroundColor: widget.scaffoldBackgroundColor,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Stack(
        children: [
          SizedBox(
              height: CustomScaffold.bodyHeight,
              width: sf.size.width,
              child: SingleChildScrollView(
                  child: CustomColumn(
                mainAxisSize: MainAxisSize.min,
                children: [
                  widget.navBarWidget ?? const SizedBox(),
                  //SizedBox(height: 8),
                  sf.maxComponents < 2
                      ? widget.centerWidget ?? const SizedBox()
                      : sf.maxComponents < 3
                          ? CustomRow(
                              children: [
                                Expanded(
                                  flex: widget.metaWidget == null ? 1 : 3,
                                  child:
                                      widget.centerWidget ?? const SizedBox(),
                                ),
                                widget.metaWidget == null
                                    ? const SizedBox()
                                    : Expanded(
                                        flex: 2,
                                        child: widget.metaWidget ??
                                            const SizedBox())
                              ],
                            )
                          : CustomRow(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                widget.sideMenu == null
                                    ? const SizedBox()
                                    : Expanded(
                                        flex: 1,
                                        child:
                                            widget.sideMenu ?? const SizedBox(),
                                      ),
                                widget.centerWidget == null
                                    ? const SizedBox()
                                    : Expanded(
                                        flex: widget.metaWidget == null
                                            ? (widget.sideMenu == null ? 1 : 4)
                                            : 3,
                                        child: widget.centerWidget ??
                                            const SizedBox(),
                                      ),
                                widget.metaWidget == null
                                    ? const SizedBox()
                                    : Expanded(
                                        flex: 2,
                                        child: widget.metaWidget ??
                                            const SizedBox(),
                                      )
                              ],
                            ),
                ],
              ))),
        ],
      ),
      bottomNavigationBar: widget.bottomAppBar,
    );
  }

  void openViewSideMenu() {
    showCustomDialog(widget.sideMenuOptionTitle,
        widget.sideMenu ?? const SizedBox(), context);
  }
}

Future<double> getNavigationBarHeight(BuildContext context) async {
  double fullHeight = MediaQuery.of(context).size.height;
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  double heightWithoutNav = MediaQuery.of(context).size.height;
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: SystemUiOverlay.values);
  return fullHeight - heightWithoutNav;
}
