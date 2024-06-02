import 'dart:async';
import 'dart:io';

import 'package:green_scout/pages/home.dart';
import 'package:green_scout/pages/leaderboard.dart';
import 'package:green_scout/pages/login_as_user.dart';
import 'package:flutter/material.dart';
import 'package:green_scout/utils/achievement_manager.dart';
import 'package:green_scout/utils/main_app_data_helper.dart';

import 'utils/app_state.dart';

class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

const appTitle = "Green Scout";

final globalNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  HttpOverrides.global = DevHttpOverrides();

  await App.start();

  WidgetsFlutterBinding.ensureInitialized();

  Timer.periodic(const Duration(seconds: 15), (timer) async {
    final matches = MainAppData.immediateMatchCache;

    // This is to test whether or not we have connection.
    // It may be wasteful but it shows our users that
    // we're connected or not.
    bool wasOnline = App.internetOn;

    await App.httpPost("/", "", ignoreOutput: true);

    if (wasOnline &&
        App.internetOff &&
        globalNavigatorKey.currentContext != null) {
      App.showMessage(
          globalNavigatorKey.currentContext!, "Lost Server Connection!");
      return;
    }

    if (!wasOnline &&
        App.internetOn &&
        globalNavigatorKey.currentContext != null) {
      App.showMessage(
          globalNavigatorKey.currentContext!, "Connected to the Server!");

      return;
    }

    if (!MainAppData.loggedIn) {
      // Just in case some cache is left over and they decided to log out.
      MainAppData.resetImmediateMatchCache();
      return;
    }

    if (matches.isNotEmpty && App.internetOn) {
      for (var match in matches) {
        final _ = await App.httpPost("dataEntry", match);

        MainAppData.confirmMatchMangled(match, App.responseSucceeded);
      }

      if (App.internetOff) {
        return;
      }

      // A little safety check to ensure that we aren't getting
      // rid of data that just got put into the list.
      if (matches.length == MainAppData.immediateMatchCache.length) {
        MainAppData.resetImmediateMatchCache();
      }
    }
  });

  Timer.periodic(const Duration(minutes: 1), (timer) async {
    if (MainAppData.loggedIn) {
      MainAppData.setUserInfo();
    }
  });

  runApp(const MyApp());

  if (MainAppData.loggedIn && MainAppData.userCertificate.isNotEmpty) {
    var connected = await App.httpPost("/", "", ignoreOutput: true);

    if (connected) {
      // Start up check to ensure that we're logged out when
      // the certificate becomes invalid on the server.
      bool postSucceeded = await App.httpPost("certificateValid", '');

      if (!postSucceeded) {
        MainAppData.loggedIn = false;
        App.gotoPage(
            globalNavigatorKey.currentContext!, const LoginPageForUsers());
      } else {
        MainAppData.setUserInfo();
      }
    }
  }

  Settings.update();
}

//These are the only 2 themes I bothered making. Feel free to make more if you want future devs, I'm just not great at color balancing.
var lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: greenMachineGreen,
    brightness: Brightness.light,
  ),
  useMaterial3: true,
);

var darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: greenMachineGreen,
    brightness: Brightness.dark,
  ),
  useMaterial3: true,
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if (MainAppData.loggedIn) {
      AchievementManager.appThemesUnlocked =
          (App.getBool("Themes Unlocked") ?? false);
    }
    return MaterialApp(
      navigatorKey: globalNavigatorKey,
      title: appTitle,
      theme: lightTheme,
      darkTheme: darkTheme,
      home:
          !MainAppData.loggedIn ? const LoginPageForUsers() : const HomePage(),
      themeAnimationCurve: Curves.easeInOut,
      themeMode: AchievementManager.appThemesUnlocked
          ? ThemeMode.system
          : ThemeMode.light,
      debugShowCheckedModeBanner: false,
    );
  }
}
