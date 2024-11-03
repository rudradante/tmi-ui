import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmiui/config/config_provider.dart';
import 'package:tmiui/config/theme.dart';
import 'package:tmiui/extensions/color.dart';

import 'custom_column.dart';
import 'custom_dialog.dart';
import 'custom_row.dart';
import 'custom_text.dart';

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
  final bool showBackButton;

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
      )})
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
      elevation: 0,
      actions: actions,
      title: FittedBox(
          child: CustomText(
              textStyle: GoogleFonts.seaweedScript(
                  textStyle: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: (widget.appBarTitleSize),
                      color: HexColor.fromHex(theme.appBarForegroundColor))),
              text: widget.title,
              color: HexColor.fromHex(theme.appBarForegroundColor),
              bold: false,
              size: widget.appBarTitleSize)),
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
    CustomScaffold.bodyHeight =
        sf.size.height - appBar.preferredSize.height - 32;
    return Scaffold(
      appBar: appBar,
      backgroundColor: widget.scaffoldBackgroundColor,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
    );
  }

  void openViewSideMenu() {
    showCustomDialog(widget.sideMenuOptionTitle,
        widget.sideMenu ?? const SizedBox(), context);
  }
}
