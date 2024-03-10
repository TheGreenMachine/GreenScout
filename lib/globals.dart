import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const greenMachineGreen = Color.fromARGB(255, 0, 167, 68);
const timerPeriodicMilliseconds = 115;


class App {
	static SharedPreferences? localStorage;

	static Future<void> setString(String key, String value) async {
		localStorage!.setString(key, value);
	}

	static Future<void> setBool(String key, bool value) async {
		localStorage!.setBool(key, value);
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