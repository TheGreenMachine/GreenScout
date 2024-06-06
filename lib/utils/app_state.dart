import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:green_scout/main.dart';
import 'package:green_scout/pages/leaderboard.dart';
import 'package:green_scout/utils/main_app_data_helper.dart';
import 'package:green_scout/utils/no_animation_material_page_route.dart';
import 'package:green_scout/utils/reference.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

const greenMachineGreen = Color.fromARGB(255, 0, 167, 68);
const timerPeriodicMilliseconds = 115;

const serverHostName = 'tagciccone.com';
const serverPort = 443;

const emptyMap = {"empty": " "};

var isDarkMode =
    MediaQuery.of(globalNavigatorKey.currentContext!).platformBrightness ==
        Brightness.dark;

Widget myPfp = const Icon(Icons.account_circle);

///This always updates the match form achievement because that's all it's currently being used for.
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

class EnumSettingOption<T> {
  EnumSettingOption(this.optionStr, T defaultValue,
      T Function(String) constructEnumFromString)
      : ref = Reference(constructEnumFromString(
            App.getString(optionStr) ?? defaultValue.toString()));

  String optionStr;
  Reference<T> ref;

  T value() {
    return ref.value;
  }

  void update() {
    App.setString(optionStr, ref.value.toString());
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

  static EnumSettingOption<LeaderboardColor> selectedLeaderboardColor =
      EnumSettingOption("Leaderboard Color", LeaderboardColor.none,
          LeaderboardColor.fromString);

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

  static Future<void> setInt(String key, int value) async {
    localStorage!.setInt(key, value);
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

  static int? getInt(String key) {
    return localStorage!.getInt(key);
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

  static void setPfp(Widget pfp) {
    myPfp = pfp;
  }

  static Widget getPfp() {
    return myPfp;
  }

  static Future<bool> httpRequest(
    String path,
    dynamic message,
    {
      Map<String, String> headers = emptyMap,
      Function(http.Response)? onGet,
      bool ignoreOutput = false,
    }
  ) async {
    dynamic genericErr;
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

    await http.post(
      uriPath,
      headers: headersToSend,
      body: message,
    ).then(
      (response) {
        if (response.statusCode == 500) {
          responseErr = "Encountered Invalid Status Code";
          log(responseErr);
        }

        if (onGet != null) {
          onGet(response);
        }

        if (ignoreOutput) {
          return;
        }

        log("Path: $path");
        log("Response Status: ${response.statusCode}");

        // Come up with better solution for logging large stuff so it doesn't
        // crash the app.
        if (response.body.length >= 1000) {
          log("Response body: ${response.body.substring(0, 1000)}\n");
        } else {
          log("Response body: ${response.body}\n");
        }
      }
    ).catchError(
      (error) {
        genericErr = error;
        log(error.toString());
      }
    );

    // Logic: If there no error, that means we successfully
    // sent a post request through the internet
    internetOn = genericErr == null;
    responseStatus = responseErr == null;

    return internetOn && responseSucceeded;
  }

  static Image getProfileImage(String arg) {
    return Image(
        image: NetworkImage("https://$serverHostName/getPfp?username=$arg"));
  }

  static Widget getGalleryImage(int index) {
    return Image(
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        height: 500,
        image: NetworkImage(
          "https://$serverHostName/gallery?index=$index",
        ));
  }

  static void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
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

  static void showAchievementUnlocked(BuildContext context, String message,
      {String? subtitle}) {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        actions: [
          TextButton(
            child: const Text('Dismiss'),
            onPressed: () =>
                ScaffoldMessenger.of(globalNavigatorKey.currentContext!)
                    .hideCurrentMaterialBanner(),
          ),
        ],
        content: Column(children: [
          Text(
            message,
            style: Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(color: Theme.of(context).colorScheme.background),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall!
                  .copyWith(color: Theme.of(context).colorScheme.background),
              textAlign: TextAlign.center,
            )
        ]),
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

  static Brightness getThemeMode() {
    return isDarkMode ? Brightness.dark : Brightness.light;
  }

  static void setThemeMode(
    Brightness themeMode,
  ) {
    isDarkMode = themeMode == Brightness.dark;
    App.setString("Theme Mode", themeMode.name);
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
