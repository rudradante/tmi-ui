import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tmiui/helpers/file_system.dart';

import '../screens/login.dart';
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

  static Future<bool> forgotPassword(String email, BuildContext context) async {
    var request = {"email": email};
    var response = await Server.post(
        '/auth/forgot-password', {}, jsonEncode(request), context);
    if (Server.isSuccessHttpCode(response.statusCode)) {
      return true;
    }
    return false;
  }

  static Future<bool> resetPassword(String email, String otp,
      String newPassword, BuildContext context) async {
    var request = {"email": email, "otp": otp, "password": newPassword};
    var response = await Server.post(
        '/auth/reset-password', {}, jsonEncode(request), context);
    if (Server.isSuccessHttpCode(response.statusCode)) {
      AppFile.delete("refresh_token");
      return true;
    }
    return false;
  }

  static void logout(BuildContext context) {
    AppFile.delete("refresh_token");
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false);
  }
}
