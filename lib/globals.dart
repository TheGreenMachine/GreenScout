import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:green_scout/no_animation_material_page_route.dart';
import 'package:green_scout/pages/preference_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

const greenMachineGreen = Color.fromARGB(255, 0, 167, 68);
const timerPeriodicMilliseconds = 115;

const serverHostName = 'tagciccone.com'; //Localhost!!!
const serverPort = 443;

var internetOn = true;

class App {
  static SharedPreferences? localStorage;

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

  static bool httpPost(String path, String message) {
    dynamic err;

    // Hack. This forces async to become sync.
    () async {
      final uriPath = Uri(
        scheme: 'https',
        host: serverHostName,
        path: path,
        port: serverPort,
      );

      await http
          .post(
        uriPath,
        headers: {"Certificate": getCertificate()},
        body: message,
      )
          .then((response) {
        log("Response Status: ${response.statusCode}");
        log("Response body: ${response.body}");
      }).catchError((error) {
        err = error;
        log(error.toString());
      });
    }();

    // Logic: If there no error, that means we successfully
    // sent a post request through the internet
    internetOn = err == null;

    return internetOn;
  }

  static bool httpGet(
      String path, String? message, Function(http.Response) onGet) {
    dynamic err;

    () async {
      final uriPath = Uri(
        scheme: 'https',
        host: serverHostName,
        path: path,
        port: serverPort,
      );

      await http
          .post(
        uriPath,
        headers: {"Certificate": getCertificate()},
        body: message,
      )
          .then((response) {
        onGet(response);
        log("Response Status: ${response.statusCode}");
        log("Response body: ${response.body}");
      }).catchError((error) {
        err = error;
        log(error.toString());
      });
    }();

    // Logic: If there no error, that means we successfully
    // sent a post request through the internet
    internetOn = err == null;

    return internetOn;
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
}
