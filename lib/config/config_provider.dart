import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:tmiui/config/app.dart';
import 'package:tmiui/config/server.dart';
import 'package:tmiui/config/theme.dart';

ConfigProvider? _configProvider;

class ConfigProvider {
  ServerConfig server;
  ThemeConfig theme;
  AppConfig appConfig;
  static bool initialized = false;

  ConfigProvider(this.server, this.theme, this.appConfig);

  static ServerConfig getServerConfig() => _configProvider!.server;
  static ThemeConfig getThemeConfig() => _configProvider!.theme;
  static AppConfig getAppConfig() => _configProvider!.appConfig;

  static Future initialize() async {
    String jsonString = await rootBundle.loadString('assets/config.json');
    var config = jsonDecode(jsonString) as Map<String, dynamic>;
    var environment = config.remove('environment');
    var environmentConfig = <String, dynamic>{};
    for (var section in config.keys) {
      environmentConfig.putIfAbsent(section,
          () => getEnvironmentSpecificSection(config[section], environment));
    }
    var serverConfig = ServerConfig.fromJson(environmentConfig['server']);
    var themeConfig = ThemeConfig.fromJson(environmentConfig['theme']);
    var appConfig = AppConfig.fromJson(environmentConfig['app']);
    _configProvider = ConfigProvider(serverConfig, themeConfig, appConfig);
  }

  static Map<String, dynamic> getEnvironmentSpecificSection(
      Map<String, dynamic> section, String environment) {
    var updatedSection = <String, dynamic>{};
    for (var key in section.keys) {
      dynamic value;
      if (section[key] is Map<String, dynamic>) {
        value = section[key][environment];
      } else {
        value = section[key];
      }
      updatedSection.putIfAbsent(key, () => value);
    }
    return updatedSection;
  }
}
