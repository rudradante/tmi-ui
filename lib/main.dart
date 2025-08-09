import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tmiui/config/config_provider.dart';
import 'package:tmiui/extensions/color.dart';
import 'package:tmiui/screens/login.dart';

import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import 'helpers/file_system.dart';

class TmiApp extends StatelessWidget {
  const TmiApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var themeConfig = ConfigProvider.getThemeConfig();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: HexColor.fromHex(themeConfig.appBarBackgroundColor),
        statusBarBrightness: Brightness.light));
    return MaterialApp(
        title: 'TMI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            datePickerTheme: DatePickerThemeData(
                inputDecorationTheme: InputDecorationTheme(
              floatingLabelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: HexColor.fromHex(themeConfig.primaryButtonColor)),
            )),
            popupMenuTheme: const PopupMenuThemeData(
                color: Colors.white,
                labelTextStyle:
                    MaterialStatePropertyAll(TextStyle(color: Colors.black)),
                textStyle: TextStyle(color: Colors.black)),
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
            dialogBackgroundColor: Colors.white,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: AppBarTheme(
              iconTheme: IconThemeData(
                  color: HexColor.fromHex(themeConfig.appBarForegroundColor)),
              backgroundColor:
                  HexColor.fromHex(themeConfig.appBarBackgroundColor),
              foregroundColor:
                  HexColor.fromHex(themeConfig.appBarForegroundColor),
              elevation: 0,
              centerTitle: false,
            ),
            splashColor: Colors.transparent,
            checkboxTheme: CheckboxThemeData(
              fillColor: MaterialStateProperty.all(
                  HexColor.fromHex(themeConfig.primaryThemeBackgroundColor)),
            ),
            pageTransitionsTheme: const PageTransitionsTheme(builders: {
              // TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
              // TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              // TargetPlatform.fuchsia: CupertinoPageTransitionsBuilder(),
              // TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
              // TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            }),
            //   scaffoldBackgroundColor:
            //       HexColor.fromHex(themeConfig.scaffoldBackgroundColor),
            shadowColor:
                HexColor.fromHex(themeConfig.primaryThemeBackgroundColor)
                    .withOpacity(0.8),
            inputDecorationTheme: InputDecorationTheme(
                labelStyle: TextStyle(
                    color: HexColor.fromHex(themeConfig.primaryThemeTextColor)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: HexColor.fromHex(
                            themeConfig.primaryThemeBackgroundColor),
                        width: 0.5)),
                border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: HexColor.fromHex(
                            themeConfig.primaryThemeBackgroundColor),
                        width: 0.5))),
            iconTheme: IconThemeData(
                color:
                    HexColor.fromHex(themeConfig.primaryThemeBackgroundColor),
                size: 18),
            primaryColor:
                HexColor.fromHex(themeConfig.primaryThemeBackgroundColor),
            textButtonTheme:
                TextButtonThemeData(style: ButtonStyle(elevation: MaterialStateProperty.all(8), foregroundColor: MaterialStateProperty.all(Colors.white), textStyle: MaterialStateProperty.all(const TextStyle()), backgroundColor: MaterialStateProperty.all(HexColor.fromHex(themeConfig.primaryThemeBackgroundColor))))),
        home: const LoginScreen());
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppFile.initialize();
  await ConfigProvider.initialize();
  await requestAndroidNotificationPermission();
  runApp(const TmiApp());
}

Future<void> requestAndroidNotificationPermission() async {
  if (!kIsWeb && Platform.isAndroid) {
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }
}
