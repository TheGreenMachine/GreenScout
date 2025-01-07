import 'dart:async';
import 'dart:io';

import 'package:green_scout/pages/home.dart';
import 'package:green_scout/pages/login_as_user.dart';
import 'package:flutter/material.dart';
import 'package:green_scout/utils/achievement_manager.dart';
import 'package:green_scout/utils/main_app_data_helper.dart';

import 'utils/app_state.dart';

/// A simple string to dictate the title of the app.
const appTitle = "Green Scout";

/// A global that allows us to easily access the current context we're in.
/// 
/// Simply access: 
/// ```dart
/// // This is an optional, so you will have to check whether or not it's null.
/// globalNavigatorKey.currentContext
/// ```
final globalNavigatorKey = GlobalKey<NavigatorState>();

class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

/// The main entry point of the app.
/// 
/// Make sure to call start up essential services
/// and logic here.
void main() async {
  HttpOverrides.global = DevHttpOverrides();

  await App.start();

  WidgetsFlutterBinding.ensureInitialized();

  Timer.periodic(const Duration(seconds: 15), (timer) async {
    final matches = MainAppData.immediateMatchCache;

    // This is used to test whether or not we're connected
    // to the server. It may be wasteful sending it every
    // 15 seconds, but it hopefully helpful information
    // for the user.
    bool wasOnline = App.internetOn;

    await App.httpRequest("/", "", ignoreOutput: true);

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
        final _ = await App.httpRequest("dataEntry", match);

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

  // This is where the app actually gets ran.
  runApp(const MyApp());
  
  if (MainAppData.loggedIn && MainAppData.userCertificate.isNotEmpty) {
    var connected = await App.httpRequest("/", "", ignoreOutput: true);

    if (connected) {
      // Start up check to ensure that we're logged out when
      // the certificate becomes invalid on the server.
      bool postSucceeded = await App.httpRequest("certificateValid", '');

      if (!postSucceeded) {
        MainAppData.loggedIn = false;
        App.gotoPage(
            globalNavigatorKey.currentContext!, const LoginPageForUsers());
      } else {
        MainAppData.setUserInfo();
      }
    }
  }

  // I honestly don't know what this logic is supposed to achieve. - Michael.
  if (AchievementManager.appThemesUnlocked.value && MainAppData.loggedIn) {
    if (!isDarkMode) {
      App.setThemeMode(Brightness.light);
    }
  } else {
    App.setThemeMode(Brightness.light);
  }

  // Make sure that before we leave the app that any settings changed in 
  // one of the settings pages gets saved.
  Settings.update();
}

//These are the only 2 themes I bothered making. Feel free to make more if you want future devs, I'm just not great at color balancing. - Tag
// 
// You'll probably have to go through some hoops to get this to work at runtime. If you truly want themes, then you're probably going
// to have to change some stuff in every page. Maybe try making a custom themes manager to hold all the color information, then you can ignore
// the context and pull the color data from there. That, at least, would be how I'd approach it. - Michael.
var lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 6, 54, 86), //    seedColor: greenMachineGreen,
    brightness: Brightness.light,
  ),
  useMaterial3: true,
);

// This theme looks a little weird - Michael.
var darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 53, 81, 173), //    seedColor: lightGreen,
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
      AchievementManager.appThemesUnlocked.value =
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
      themeMode: AchievementManager.appThemesUnlocked.value
          ? ThemeMode.dark //leon darkmode here
          : ThemeMode.light,
      debugShowCheckedModeBanner: false,
    );
  }
}
