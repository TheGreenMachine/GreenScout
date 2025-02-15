import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:green_scout/main.dart';
import 'package:green_scout/pages/leaderboard.dart';
import 'package:green_scout/utils/main_app_data_helper.dart';
import 'package:green_scout/utils/no_animation_material_page_route.dart';
import 'package:green_scout/utils/reference.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

const greenMachineGreen = Color.fromARGB(255, 0, 167, 67);
const lightGreen = Color.fromARGB(255, 81, 222, 121);
const timerPeriodicMilliseconds = 115;

const serverHostName = 'localhost'; // TODO Put your server name here! SERVER STUFF (localhost is the default)
const serverPort = 8080; //swap port based on TLS [backend main.go]

const emptyMap = {"empty": " "};

enum ThemeColor {
  dark,
  light,
  green;

  static ThemeColor fromString(String str) {
    switch (str) {
      case "dark":
        return dark;
      case "green":
        return green;
      default:
        return light;
    }
  }
}

var isDarkMode =
    MediaQuery.of(globalNavigatorKey.currentContext!).platformBrightness ==
        Brightness.dark;

Widget myPfp = const Icon(Icons.account_circle);

/// A wrapper class that handles the logic for updating and retrieving 
/// boolean setting values.
/// 
/// NOTE: This always updates the match form achievement because that's all it's currently being used for. - Tag
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

/// A wrapper class that handles the logic for updating and retrieving 
/// enum setting values.
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

  static EnumSettingOption<ThemeColor> selectedThemeColor =
      EnumSettingOption("Leaderboard Color", ThemeColor.light,
          ThemeColor.fromString);

  static void update() {
    flipNumberCounter.update();
    sideBarLeftSided.update();
    enableMatchRescouting.update();
  }
}

/// The main class that stores everything related to the state of the program.
/// 
/// Which includes
/// - Whether or not a connection to the server is available
/// - The status of the latest response.
/// - Storage for items like username, display name, uuids, etc...
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

  // These are meant to make it easier to access stored
  // data via the shared preferences api.
  /* START OF SHARED PREFERENCE WRAPPERS */

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

  /* END OF SHARED PREFERENCE WRAPPERS */

  /// A function meant to be called at the entry point of 
  /// the program.
  /// 
  /// Initializes the shared preferences api for the app.
  static Future<void> start() async {
    localStorage = await SharedPreferences.getInstance();
  }

  /// A wrapper function to easily navigate to another page/widget
  /// in the app. 
  /// 
  /// How to use it:
  /// ```dart
  /// App.gotoPage(context, const SettingsPage());
  /// 
  /// // Additionally, you can make it add a back button for going
  /// // back a page.
  /// App.gotoPage(context, const SettingsPage(), canGoBack: true);
  /// ```
  static void gotoPage(BuildContext context, Widget page,
      {bool canGoBack = false}) {
    final navigator = Navigator.of(context);
    final route = NoAnimationMaterialPageRoute(
      builder: (context) => page,
    );

    if (canGoBack) {
      navigator.push(route);
    } else {
      if (navigator.canPop()) {
        navigator.pop();
      }

      navigator.pushReplacement(route);
    }
  }

  static void setPfp(Widget pfp) {
    myPfp = pfp;
  }

  static Widget getPfp() {
    return myPfp;
  }

  /// A generic wrapper to make requesting items from the server
  /// simpler.
  /// 
  /// It contains logic to ensure that if a request does fail,
  /// we can report it back in several ways.
  /// 
  /// A real example of how'd you use it for a post request and using custom headers (found in `individual_admin_assign_matches.dart`):
  /// ```dart
  /// App.httpRequest(
  ///   "/addSchedule",
  ///   match.toJson(), 
  ///   headers: {
  ///     "userInput": 
  ///     match.scouterName,
  ///   },
  /// );
  /// ```
  /// 
  /// A real example of how'd you use it for a get request (found in `settings/debug_info.dart`):
  /// ```dart
  /// App.httpRequest(
  ///   "generalInfo", 
  ///   "", 
  ///   onGet: (response) {
  ///     // Logic related to getting general info...
  ///   },
  /// );
  /// ```
  static Future<bool> httpRequest(
    String path,
    dynamic message, {
    Map<String, String> headers = emptyMap,
    Function(http.Response)? onGet,
    bool ignoreOutput = false,
  }) async {
    dynamic genericErr;
    dynamic responseErr;

    final uriPath = Uri(
      scheme: 'http',
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
      // This is a case of where we successfully get something back
      // but what is given is not valid for the app to use.
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
    }).catchError((error) {
      genericErr = error;

      log("Path: $path");
      log(error.toString());
    });

    // Logic: If there is no error, that means we successfully
    // sent a request through the internet.
    internetOn = genericErr == null;
    responseStatus = responseErr == null;

    return internetOn && responseSucceeded;
  }

  static Image getProfileImage(String arg) {
    return Image(
        image: NetworkImage("http://$serverHostName:$serverPort/getPfp?username=$arg"));
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
          "http://$serverHostName:$serverPort/gallery?index=$index",
        ));
  }

  /// A simplified way to show a message to the user via the 
  /// built-in snackbar.
  /// 
  /// An example of how this can be used:
  /// ```dart
  /// App.showMessage(context, "You've scouted 1000 matches!");
  /// ```
  /// Results in:
  /// ```txt
  /// -----------------------------------------------------
  /// | You've scouted 1000 matches!                      |
  /// -----------------------------------------------------
  /// ```
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

  /// Similar to `showMessage`, this function shows a message
  /// and contains an additional button with it that can be 
  /// programmed with a special action.
  /// 
  /// An example of how this could be used:
  /// ```dart
  /// App.promptAction(context, "Deleted Record", "(Undo?)", () => log("You undid the operation!"));
  /// ```
  /// Results in:
  /// ```txt
  /// -----------------------------------------------------
  /// |  Deleted Record                         (Undo?)   |
  /// -----------------------------------------------------
  /// ```
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

  /// A simple function for creating interactive prompts.
  /// 
  /// An example of how it could be used:
  /// ```dart
  /// App.promptAlert(
  ///   context,
  ///   "Would you like to save this match?",
  ///   "By doing this, you understand that you'll be unable to edit it any further.",
  ///   [
  ///     ("No?", null), // defaults to cancelling and exiting the prompt box.
  ///     ("Yes?", () { 
  ///       // Do some logic here...
  ///     }),
  ///   ],
  /// );
  /// 
  /// ```
  /// Results in:
  /// ```txt
  /// -----------------------------------------------------
  /// | Would you like to save this match?                |
  /// |                                                   |
  /// | By doing this, you understand that you'll be      |
  /// | unable to edit it any further.                    |
  /// |                                                   |
  /// |                                       No?   Yes?  |
  /// -----------------------------------------------------
  /// ```
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
