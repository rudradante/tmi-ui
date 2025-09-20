// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:tmiui/models.dart/login_user.dart';

import '../config/config_provider.dart';
import '../custom_widgets/message_dialog.dart';
import '../custom_widgets/pending_dialog.dart';

class Server {
  static bool isSuccessHttpCode(int code) {
    if (code >= 200 && code < 300) return true;
    return false;
  }

  static final Client _http = Client();
  static final Map<String, String> __headers = {
    "Content-Type": "application/json",
    "Authorization": LoginUser.currentLoginUser.getBearerToken()
  };
  static Map<String, String> getUpdatedHeader() {
    __headers["Authorization"] = LoginUser.currentLoginUser.getBearerToken();
    return __headers;
  }

  static Future<Response> get(
      String path, Map<String, String> query, BuildContext context,
      {bool showPendingDialog = true}) async {
    bool isOpen = true;
    Response response;
    try {
      if (showPendingDialog) {
        showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context) => const PendingDialog(title: "")).then((value) {
          isOpen = false;
        });
      }
      var config = ConfigProvider.getServerConfig();
      Uri uri = Uri(
          scheme: config.protocol,
          host: config.baseUrl,
          path: path,
          queryParameters: query);
      response = await _http.get(uri, headers: getUpdatedHeader());
      if (showPendingDialog && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      if (Server.isSuccessHttpCode(response.statusCode)) return response;
    } catch (e) {
      if (showPendingDialog && Navigator.canPop(context) && isOpen) {
        Navigator.pop(context);
      }
      response = Response('Cannot connect to server', 500);
      print(e);
    }
    if (response.statusCode == 401) {
      await logout(context);
      return response;
    }
    await showMessageDialog(
        "Hey There!", parseMessageFromResponse(response.body), context);
    // if (response.statusCode == 401) {
    //   Navigator.pushAndRemoveUntil(
    //       context,
    //       MaterialPageRoute(builder: (context) => LoginPage()),
    //       (route) => false);
    return response;
  }

  static Future<void> logout(BuildContext context) async {
    await showMessageDialog("Hey There!",
        "Login session has expired. You need to login again", context);
    LoginUser.logout(context);
  }

  static String parseMessageFromResponse(String body) {
    try {
      var jsonDecoded = jsonDecode(body) as List;
      if (jsonDecoded == null || jsonDecoded.isEmpty) return body;
      return jsonDecoded[0]['message'] ?? body;
    } catch (err) {
      print(err);
      return body;
    }
  }

  static Future<Response> post(
      String path, Map<String, String> query, String body, BuildContext context,
      {bool showPendingDialog = true}) async {
    Response response;
    bool isOpen = true;
    try {
      if (showPendingDialog) {
        showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context) => const PendingDialog(title: "")).then((value) {
          isOpen = false;
        });
      }
      var config = ConfigProvider.getServerConfig();
      Uri uri = Uri(
          scheme: config.protocol,
          host: config.baseUrl,
          path: path,
          queryParameters: query);
      response = await _http.post(uri, body: body, headers: getUpdatedHeader());
      if (showPendingDialog && Navigator.canPop(context) && isOpen) {
        Navigator.pop(context);
      }
      if (Server.isSuccessHttpCode(response.statusCode)) return response;
    } catch (e) {
      if (showPendingDialog && Navigator.canPop(context) && isOpen) {
        Navigator.pop(context);
      }
      print(e);
      response = Response('Cannot connect to server', 500);
    }
    if (response.statusCode == 401) {
      await logout(context);
      return response;
    }
    await showMessageDialog(
        "Hey There!", parseMessageFromResponse(response.body), context);
    return response;
  }

  static Future<Response> update(
      String path, Map<String, String> query, String body, BuildContext context,
      {bool showPendingDialog = true}) async {
    Response response;
    bool isOpen = true;
    try {
      if (showPendingDialog) {
        showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context) => const PendingDialog(title: "")).then((value) {
          isOpen = false;
        });
      }

      var config = ConfigProvider.getServerConfig();
      Uri uri = Uri(
          scheme: config.protocol,
          host: config.baseUrl,
          path: path,
          queryParameters: query);
      response = await _http.put(uri, body: body, headers: getUpdatedHeader());
      if (showPendingDialog && Navigator.canPop(context) && isOpen) {
        Navigator.pop(context);
      }
      if (Server.isSuccessHttpCode(response.statusCode)) return response;
    } catch (e) {
      if (showPendingDialog && Navigator.canPop(context) && isOpen) {
        Navigator.pop(context);
      }
      print(e);
      response = Response('Cannot connect to server', 500);
    }
    if (response.statusCode == 401) {
      await logout(context);
      return response;
    }
    await showMessageDialog(
        "Hey There!", parseMessageFromResponse(response.body), context);
    return response;
  }

  static Future<Response> delete(
      String path, Map<String, String> query, BuildContext context,
      {bool showPendingDialog = true}) async {
    Response response;
    bool isOpen = true;
    try {
      if (showPendingDialog) {
        showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context) => const PendingDialog(title: "")).then((value) {
          isOpen = false;
        });
      }

      var config = ConfigProvider.getServerConfig();
      Uri uri = Uri(
          scheme: config.protocol,
          host: config.baseUrl,
          path: path,
          queryParameters: query);
      response = await _http.delete(uri, headers: getUpdatedHeader());
      if (showPendingDialog && Navigator.canPop(context) && isOpen) {
        Navigator.pop(context);
      }
      if (Server.isSuccessHttpCode(response.statusCode)) return response;
    } catch (e) {
      if (showPendingDialog && Navigator.canPop(context) && isOpen) {
        Navigator.pop(context);
      }
      print(e);
      response = Response('Cannot connect to server', 500);
    }
    if (response.statusCode == 401) {
      await logout(context);
      return response;
    }
    await showMessageDialog(
        "Hey There!", parseMessageFromResponse(response.body), context);
    return response;
  }

  static Future<Response> upload(String path, String jsonString,
      Map<String, String> query, dynamic platformFile, BuildContext context,
      {dynamic files, bool showPendingDialog = true}) async {
    //query.putIfAbsent('authorization', () => Authorization.accessToken);
    Response response;
    bool isOpen = true;
    try {
      if (showPendingDialog) {
        showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context) => const PendingDialog(title: "")).then((value) {
          isOpen = false;
        });
      }

      var config = ConfigProvider.getServerConfig();
      Uri uri = Uri(
          scheme: config.protocol,
          host: config.baseUrl,
          path: path,
          queryParameters: query);
      MultipartRequest request = MultipartRequest("POST", uri);
      if (files == null) {
        // request.files.add(MultipartFile(
        //   "file",
        //   platformFile.readStream,
        //   platformFile.size,
        //   filename: (platformFile as PlatformFile).name,
        // ));
      } else {
        // for (var i = 0; i < files.length; i++) {
        //   request.files.add(MultipartFile(
        //     "files",
        //     files[i].readStream,
        //     files[i].size,
        //     filename: (files[i] as PlatformFile).name,
        //   ));
        // }
      }
      // request.headers.putIfAbsent(
      // "authorization", () => "Bearer ${Authorization.accessToken}");
      // request.headers.putIfAbsent(
      //"requested-by", () => config.requestedBy.name.toLowerCase());
      request.fields.putIfAbsent('data', () => jsonString);
      response = await Response.fromStream(await request.send());
      if (!Server.isSuccessHttpCode(response.statusCode)) {
        await showMessageDialog(
            "Hey There!", parseMessageFromResponse(response.body), context);
      }
      if (showPendingDialog && Navigator.canPop(context) && isOpen) {
        Navigator.pop(context);
      }
      return response;
    } catch (e) {
      if (showPendingDialog && Navigator.canPop(context) && isOpen) {
        Navigator.pop(context);
      }

      print(e);
      return Response("Something Went Wrong", 500);
    }
  }
}
