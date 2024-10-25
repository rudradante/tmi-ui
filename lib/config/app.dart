class AppConfig {
  int timeZoneOffset = 330 * 60;

  AppConfig(this.timeZoneOffset);

  static AppConfig fromJson(Map<String, dynamic> json) {
    return AppConfig(int.parse(json['timeZoneOffset'].toString()));
  }
}
