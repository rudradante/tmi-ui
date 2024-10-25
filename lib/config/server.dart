class ServerConfig {
  String protocol;
  String baseUrl;
  int port;

  ServerConfig(this.protocol, this.baseUrl, this.port);

  static ServerConfig fromJson(Map<String, dynamic> json) {
    return ServerConfig(
        json['protocol'], json['baseUrl'], int.parse(json['port'].toString()));
  }
}
