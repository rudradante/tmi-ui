// ignore_for_file: library_prefixes

import 'dart:io' as SystemStorage;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tmiui/custom_widgets/message_dialog.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:universal_html/html.dart';

class AppFile {
  static String appDirectory = "";

  static Future<bool> initialize() async {
    if (!kIsWeb) {
      appDirectory = (await getApplicationDocumentsDirectory()).path;
      SystemStorage.Directory temp =
          SystemStorage.Directory("$appDirectory/temp");
      if (!(await temp.exists())) {
        await temp.create();
      }
    }
    return kIsWeb ||
        (appDirectory.isNotEmpty &&
            SystemStorage.Directory("$appDirectory/temp").existsSync());
  }

  static String? readAsString(String filename) {
    try {
      String? content;
      if (kIsWeb) {
        content = window.localStorage.containsKey(filename)
            ? (window.localStorage[filename] ?? "")
            : null;
      } else {
        SystemStorage.File file = SystemStorage.File("$appDirectory/$filename");
        if (file.existsSync()) content = file.readAsStringSync();
      }
      return content;
    } catch (err) {
      return null;
    }
  }

  static List<String> listFiles(String rootDir) {
    List<String> files = [];
    if (kIsWeb) {
      files = window.localStorage.keys
          .where((element) => element.substring(0, rootDir.length) == rootDir)
          .toList();
    } else {
      SystemStorage.Directory directory =
          SystemStorage.Directory("$appDirectory/$rootDir");
      if (!directory.existsSync()) directory.createSync();
      List<SystemStorage.FileSystemEntity> fileEntities = [];
      for (var item in directory.listSync()) {
        if (item.statSync().type == SystemStorage.FileSystemEntityType.file) {
          fileEntities.add(item);
        }
      }
      files = fileEntities.map((e) => e.path).toList();
    }
    return files;
  }

  static bool writeAsString(String filename, String content) {
    try {
      if (kIsWeb) {
        window.localStorage.remove(filename);
        window.localStorage.putIfAbsent(filename, () => content);
        return true;
      }
      SystemStorage.File file = SystemStorage.File("$appDirectory/$filename");
      if (file.existsSync()) file.deleteSync();
      file.createSync();
      file.writeAsStringSync(content);
      return true;
    } catch (err) {
      return false;
    }
  }

  static bool delete(String filename) {
    try {
      if (kIsWeb) {
        window.localStorage.remove(filename);
        return true;
      }
      SystemStorage.File file = SystemStorage.File("$appDirectory/$filename");
      file.deleteSync();
      return true;
    } catch (err) {
      return false;
    }
  }

  static Future openFile(String path, BuildContext context) async {
    if (kIsWeb) {
      await showMessageDialog(
          "Unsupported feature",
          "Opening local files is not supported in web version. Please download desktop/app to open local references",
          context);
      return;
    }
    if (readAsString(path) != null) {
      await launchUrlString(path);
    } else {
      await showMessageDialog(
          "File not found",
          "Cannot find the specified file. Make sure the file exists in given location",
          context);
    }
  }
}
