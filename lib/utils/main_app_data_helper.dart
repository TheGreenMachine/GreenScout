import 'dart:convert';
import 'dart:developer';

import 'package:green_scout/utils/app_state.dart';

/// A Helper Class That Centralizes All Data Integral
/// For The App To Run.
class MainAppData {
  static const _scouterKey = "Scouter";
  static const _displayNameKey = "Display Name";
  static const _loginStatusKey = "Logged In";
  static const _userRoleKey = "User Role";
  static const _adminStatusKey = "Admin";
  static const _userCertificateKey = "User Certificate";
  static const _userUUIDKey = "User UUID";
  static const _allTimeMatchCacheKey = "Match JSONS";
  static const _tempMatchCacheKey = "TEMP Match JSONS";

  static void autoSetAdminStatus() {
    isAdmin = userRole == "admin" || userRole == "super";
  }

  static String get scouterName {
    return App.getString(_scouterKey) ?? "";
  }

  static set scouterName(String value) {
    App.setString(_scouterKey, value);
  }

  static String get displayName {
    return App.getString(_displayNameKey) ?? scouterName;
  }

  static set displayName(String value) {
    App.setString(_displayNameKey, value);
  }

  static bool get loggedIn {
    return App.getBool(_loginStatusKey) ?? false;
  }

  static set loggedIn(bool value) {
    App.setBool(_loginStatusKey, value);
  }

  static bool get isAdmin {
    return App.getBool(_adminStatusKey) ?? false;
  }

  static set isAdmin(bool value) {
    App.setBool(_adminStatusKey, value);
  }

  static String get userRole {
    return App.getString(_userRoleKey) ?? "None";
  }

  static set userRole(String value) {
    App.setString(_userRoleKey, value);
  }

  static String get userCertificate {
    return App.getString(_userCertificateKey) ?? "";
  }

  static set userCertificate(String value) {
    App.setString(_userCertificateKey, value);
  }

  static String get userUUID {
    return App.getString(_userUUIDKey) ?? "";
  }

  static set userUUID(String value) {
    App.setString(_userUUIDKey, value);
  }

  static List<String> get immediateMatchCache {
    return App.getStringList(_tempMatchCacheKey) ?? [];
  }

  static List<String> get allTimeMatchCache {
    return App.getStringList(_allTimeMatchCacheKey) ?? [];
  }

  static void addToMatchCache(String matchJSON) {
    App.setStringList(
      _tempMatchCacheKey,
      [
        ...immediateMatchCache,
        matchJSON,
      ],
    );

    // So... what we're doing is concatenating the old list
    // of match cache and then combining it with the new data
    // we just got.
    //
    // The reason we're using a set (which is '<String>{}') is because
    // a set as a structure has the neat property of only allowing one
    // instance of an item at a time. So, essentially they are a list
    // which only contains unique elements.
    App.setStringList(
      _allTimeMatchCacheKey,
      <String>{...allTimeMatchCache, ...immediateMatchCache}.toList(),
    );
  }

  static void confirmMatchMangled(String jsonStr, bool success) {
    final allTime = allTimeMatchCache.toSet();

    try {
      final json = jsonDecode(jsonStr);
      json["Mangled"] = !success;

      allTime.remove(jsonStr);
      allTime.add(jsonEncode(json));
    } catch (e) {
      // Do nothing...
      log("Captured exception while confirming matches: $e");
    }

    App.setStringList(_allTimeMatchCacheKey, allTime.toList());
  }

  static void resetImmediateMatchCache() {
    log("Resetting immediate match cache");
    App.setStringList(_tempMatchCacheKey, []);
  }

  static void resetAllTimeMatchCache() {
    log("Resetting all time match cache");
    App.setStringList(_allTimeMatchCacheKey, []);
  }

  static void resetMatchCache() {
    log("Resetting all match cache (all time and immediate)");
    App.setStringList(_tempMatchCacheKey, []);
    App.setStringList(_allTimeMatchCacheKey, []);
  }

  static Future<bool> updateUserData(String newDisplayName) async {
    return App.httpPostWithHeaders("/setDisplayName", "", {
      "Username": MainAppData.scouterName,
      "displayName": newDisplayName,
    });
  }
}
