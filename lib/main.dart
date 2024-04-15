import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:green_scout/pages/home.dart';
import 'package:green_scout/pages/login_as_user.dart';
import 'package:flutter/material.dart';

import 'pages/navigation_layout.dart';
import 'pages/preference_helpers.dart';
import 'globals.dart';

class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

final globalNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  HttpOverrides.global = DevHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();

  await App.start();

  Timer.periodic(const Duration(seconds: 15), (timer) async {
    final matches = getImmediateMatchCache();

    // This is to test whether or not we have connection.
    // It may be wasteful but it shows our users that
    // we're connected or not.
    bool wasOnline = App.internetOn;

    await App.httpPost("/", "", ignoreOutput: true);

    if (wasOnline &&
        App.internetOff &&
        globalNavigatorKey.currentContext != null) {
      App.showMessage(
          globalNavigatorKey.currentContext!, "Lost Internet Connection!");
      return;
    }

    if (!wasOnline &&
        App.internetOn &&
        globalNavigatorKey.currentContext != null) {
      App.showMessage(
          globalNavigatorKey.currentContext!, "Connected to the Internet!");
      return;
    }

    if (!loggedInAlready()) {
      // Just in case some cache is left over and they decided to log out.
      resetImmediateMatchCache();
      return;
    }

    if (matches.isNotEmpty && App.internetOn) {
      for (var match in matches) {
        final _ = await App.httpPost("dataEntry", match);

        confirmMatchMangled(match, App.responseSucceeded);
      }

      if (App.internetOff) {
        return;
      }

      // A little safety check to ensure that we aren't getting
      // rid of data that just got put into the list.
      if (matches.length == getImmediateMatchCache().length) {
        resetImmediateMatchCache();
      }
    }
  });

  runApp(const MyApp());

  Settings.update();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: globalNavigatorKey,

      title: 'Green Scout',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: greenMachineGreen),
        useMaterial3: true,
      ),
      // TODO: later
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            brightness: Brightness.dark, seedColor: greenMachineGreen),
        // primaryTextTheme: Typography.blackCupertino
      ),
      home: !loggedInAlready() ? const LoginPageForUsers() : const HomePage(),
      //   home: const LoginPageForGuest(),
      // routes: navigationLayout,
      themeAnimationCurve: Curves.easeInOut,
      themeMode: ThemeMode.light,

      debugShowCheckedModeBanner: false,
    );
  }
}
