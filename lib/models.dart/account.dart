import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:tmiui/models.dart/login_user.dart';

import '../server/request.dart';

class Account {
  String firstName, lastName, email;
  Account(this.firstName, this.lastName, this.email);

  static Account fromJson(Map<String, dynamic> json) {
    return Account(json["First_Name"], json["Last_Name"], json["Email"]);
  }

  Map<String, dynamic> toJson() {
    return {"firstName": firstName, "lastName": lastName, "email": email};
  }

  static Future<bool> initiateSignUp(String firstName, String lastName,
      String email, BuildContext context) async {
    var request = {
      "firstName": firstName,
      "lastName": lastName,
      "email": email
    };
    var response = await Server.post('/auth', {}, jsonEncode(request), context);
    return Server.isSuccessHttpCode(response.statusCode);
  }

  static Future<LoginUser?> createAccount(String firstName, String lastName,
      String email, String otp, String password, BuildContext context) async {
    var request = {
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "otp": otp,
      "password": password
    };
    var response = await Server.post('/auth', {}, jsonEncode(request), context);
    if (Server.isSuccessHttpCode(response.statusCode)) {
      return await LoginUser.login(email, password, context);
    }
    return null;
  }

  static Future<Account?> getAccountDetails(BuildContext context) async {
    var response = await Server.get('/auth', {}, context);
    if (Server.isSuccessHttpCode(response.statusCode)) {
      return Account.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    return null;
  }

  static Future<void> updateAccount(
      String firstName, String lastName, BuildContext context) async {
    var request = {"firstName": firstName, "lastName": lastName};
    await Server.update('/auth', {}, jsonEncode(request), context);
  }
}
