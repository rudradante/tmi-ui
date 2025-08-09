import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tmiui/helpers/file_system.dart';

import '../server/request.dart';

class LoginUser {
  String userId, username, accessToken, refreshToken;
  LoginUser(this.userId, this.username, this.accessToken, this.refreshToken);

  static LoginUser currentLoginUser = LoginUser("", "", "", "");

  static LoginUser fromJson(Map<String, dynamic> json) {
    return LoginUser(json["userId"] ?? "", json["email"] ?? "",
        json["accessToken"] ?? "", json["refreshToken"] ?? "");
  }

  String getBearerToken() {
    return 'Bearer ${accessToken.trim()}';
  }

  static Future<LoginUser?> login(
      String email, String password, BuildContext context) async {
    var request = {"email": email, "password": password};
    var response =
        await Server.post('/auth/login', {}, jsonEncode(request), context);
    if (Server.isSuccessHttpCode(response.statusCode)) {
      currentLoginUser =
          LoginUser.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      AppFile.writeAsString("refresh_token", currentLoginUser.refreshToken);
      return currentLoginUser;
    }
    return null;
  }

  static Future<LoginUser?> refresh(
      String refreshToken, BuildContext context) async {
    var request = {"refreshToken": refreshToken};
    var response = await Server.post(
        '/auth/refresh-token', {}, jsonEncode(request), context);
    if (Server.isSuccessHttpCode(response.statusCode)) {
      currentLoginUser =
          LoginUser.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      return currentLoginUser;
    }
    return null;
  }
}
