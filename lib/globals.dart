import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:green_scout/pages/preference_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

const greenMachineGreen = Color.fromARGB(255, 0, 167, 68);
const timerPeriodicMilliseconds = 115;

const serverHostName = '127.0.0.1'; //Localhost!!!
const serverPort = 443;

var internetOff = false;

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

		await http.post(
			uriPath,
			headers: { "Certificate": getCertificate() },
			body: message,
		).then((response) {
			log("Response Status: ${response.statusCode}");
			log("Response body: ${response.body}");
		}).catchError((error) {
			err = error;
			log(error.toString());
		});
	}();

	if (err != null) {
		return false;
	}

	return true;
  }

  static String? httpGet(String path) {
	// TODO: Implement this wrapper.

	// TODO: Implement Internet Off checker.

	return null;
  }
}
