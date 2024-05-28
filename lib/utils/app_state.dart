import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:green_scout/utils/main_app_data_helper.dart';
import 'package:green_scout/utils/no_animation_material_page_route.dart';
import 'package:green_scout/utils/reference.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

const greenMachineGreen = Color.fromARGB(255, 0, 167, 68);
const timerPeriodicMilliseconds = 115;

const serverHostName = 'tagciccone.com'; //Localhost!!!
const serverPort = 443;

const emptyMap = {"empty": " "};

class BoolSettingOption {
  BoolSettingOption(
    this.optionStr,
    bool defaultValue,
  ) : ref = Reference(App.getBool(optionStr) ?? defaultValue);

  String optionStr;
  Reference<bool> ref;

  bool value() {
    return ref.value;
  }

  void update() {
    App.setBool(optionStr, ref.value);
  }
}

class Settings {
  static BoolSettingOption flipNumberCounter = BoolSettingOption(
    "[Settings] Flip Number Counter",
    false,
  );

  static BoolSettingOption sideBarLeftSided = BoolSettingOption(
    "[Settings] Side Bar On Left Side",
    false,
  );

  static BoolSettingOption enableMatchRescouting = BoolSettingOption(
    "[Settings] Enable Match Rescouting",
    false,
  );

  static void update() {
    flipNumberCounter.update();
    sideBarLeftSided.update();
    enableMatchRescouting.update();
  }
}

class App {
  static SharedPreferences? localStorage;
  static var internetOn = true;
  static var responseStatus = false;

  static bool get internetOff {
    return !internetOn;
  }

  static bool get responseFailed {
    return !responseStatus;
  }

  static bool get responseSucceeded {
    return responseStatus;
  }

  static Future<void> setStringList(String key, List<String> value) async {
    localStorage!.setStringList(key, value);
  }

  static Future<void> setString(String key, String value) async {
    localStorage!.setString(key, value);
  }

  static Future<void> setBool(String key, bool value) async {
    localStorage!.setBool(key, value);
  }

  static List<String>? getStringList(String key) {
    return localStorage!.getStringList(key);
  }

  static String? getString(String key) {
    return localStorage!.getString(key);
  }

  static bool? getBool(String key) {
    return localStorage!.getBool(key);
  }

  static Future<void> start() async {
    localStorage = await SharedPreferences.getInstance();
  }

  static void gotoPage(BuildContext context, Widget page,
      {bool canGoBack = false}) {
    final navigator = Navigator.of(context);

    if (canGoBack) {
      navigator.push(
        NoAnimationMaterialPageRoute(
          builder: (context) => page,
        ),
      );

      return;
    }

    if (navigator.canPop()) {
      navigator.pop();
    }

    navigator.pushReplacement(
      NoAnimationMaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }

  static Future<bool> httpPost(String path, String message,
      {bool ignoreOutput = false}) async {
    dynamic err;
    dynamic responseErr;

    final uriPath = Uri(
      scheme: 'https',
      host: serverHostName,
      path: path,
      port: serverPort,
    );

    await http
        .post(
      uriPath,
      headers: {
        "Certificate": MainAppData.userCertificate,
      },
      body: message,
    )
        .then((response) {
      if (response.statusCode == 500) {
        responseErr = "Encountered Invalid Status Code";
        log(responseErr);
      }

      if (ignoreOutput) {
        return;
      }

      log("Response Status: ${response.statusCode}");
      log("Response body: ${response.body}");
    }).catchError((error) {
      err = error;
      log(error.toString());
    });

    // Logic: If there no error, that means we successfully
    // sent a post request through the internet
    internetOn = err == null;
    responseStatus = responseErr == null;

    return internetOn && responseErr == null;
  }

  static Future<bool> httpPostWithHeaders(
      String path, String message, Map<String, String> headers,
      {bool ignoreOutput = false}) async {
    dynamic err;
    dynamic responseErr;

    final uriPath = Uri(
      scheme: 'https',
      host: serverHostName,
      path: path,
      port: serverPort,
    );

    Map<String, String> headersToSend = {
      "Certificate": MainAppData.userCertificate,
      "uuid": MainAppData.userUUID,
    };
    headersToSend.addAll(headers);

    await http
        .post(
      uriPath,
      headers: headersToSend,
      body: message,
    )
        .then((response) {
      if (response.statusCode == 500) {
        responseErr = "Encountered Invalid Status Code";
        log(responseErr);
      }

      if (ignoreOutput) {
        return;
      }

      log("Response Status: ${response.statusCode}");
      log("Response body: ${response.body}");
    }).catchError((error) {
      err = error;
      log(error.toString());
    });

    // Logic: If there no error, that means we successfully
    // sent a post request through the internet
    internetOn = err == null;
    responseStatus = responseErr == null;

    return internetOn && responseErr == null;
  }

  static Future<bool> httpGet(
      String path, String? message, Function(http.Response) onGet,
      [Map<String, String> headers = emptyMap]) async {
    dynamic err;
    dynamic responseErr;

    final uriPath = Uri(
      scheme: 'https',
      host: serverHostName,
      path: path,
      port: serverPort,
    );

    Map<String, String> headersToSend = {
      "Certificate": MainAppData.userCertificate
    };

    headersToSend.addAll(headers);
    await http
        .post(
      uriPath,
      headers: headersToSend,
      body: message,
    )
        .then((response) {
      if (response.statusCode == 500) {
        responseErr = "Encountered Invalid Status Code";
        log(responseErr);
      } else {
        onGet(response);
      }

      log("Response Status: ${response.statusCode}");
      log("Response body: ${response.body}");
    }).catchError((error) {
      err = error;
      log(error.toString());
    });

    // Logic: If there no error, that means we successfully
    // sent a post request through the internet
    internetOn = err == null;
    responseStatus = responseErr == null;

    return internetOn && responseErr == null;
  }

  static void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: Theme.of(context)
              .textTheme
              .labelLarge!
              .copyWith(color: Theme.of(context).colorScheme.background),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Theme.of(context).colorScheme.onBackground,
      ),
    );
  }

  static void promptAction(BuildContext context, String message,
      String actionMessage, void Function() onPressed) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: Theme.of(context)
              .textTheme
              .labelLarge!
              .copyWith(color: Theme.of(context).colorScheme.background),
          textAlign: TextAlign.left,
        ),
        backgroundColor: Theme.of(context).colorScheme.onBackground,
        action: SnackBarAction(
          textColor: Theme.of(context).colorScheme.background,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          label: actionMessage,
          onPressed: onPressed,
        ),
      ),
    );
  }

  static void promptAlert(BuildContext context, String title,
      String? mainMessage, List<(String, void Function()?)> actions) {
    void defaultAlertCancel() {
      Navigator.of(context).pop();
    }

    List<Widget> actionButtons = [];

    for (final action in actions) {
      actionButtons.add(
        TextButton(
          onPressed: action.$2 ?? defaultAlertCancel,
          child: Text(action.$1),
        ),
      );
    }

    final alert = AlertDialog(
      title: Text(title),
      content: mainMessage != null ? Text(mainMessage) : null,
      actions: actionButtons,
    );

    // Hack. Force async to become sync.
    () async {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }();
  }
}
