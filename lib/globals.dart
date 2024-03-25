import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const greenMachineGreen = Color.fromARGB(255, 0, 167, 68);
const timerPeriodicMilliseconds = 115;

const serverHostName = '127.0.0.1'; //Localhost!!!!

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
}
