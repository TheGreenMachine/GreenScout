import 'dart:convert';
import 'dart:developer';

import 'package:green_scout/utils/app_state.dart';

void setScouterName(String name) {
  App.setString("Scouter", name);
}

String getScouterName() {
  return App.getString("Scouter") ?? "";
}

bool loggedInAlready() {
  final loggedIn = App.getBool("Logged In");

  return loggedIn != null && loggedIn;
}

void setLoginStatus(bool value) {
  App.setBool("Logged In", value);
}

void autoSetAdminStatus() {
  final role = getUserRole();

  setAdminStatus(role == "admin" || role == "super");
}

bool isAdmin() {
  final admin = App.getBool("Admin");

  return admin != null && admin;
}

void setAdminStatus(bool value) {
  App.setBool("Admin", value);
}

String getCertificate() {
  final certificate = App.getString("User Certificate");

  return certificate ?? "";
}

void storeCertificate(String certificate) {
  App.setString("User Certificate", certificate);
}

String getUserUUID() {
  final uuid = App.getString("User UUID");

  return uuid ?? "";
}

void storeUserUUID(String uuid) {
  App.setString("User UUID", uuid);
}

void storeUserRole(String role) {
  App.setString("User Role", role);
}

String getUserRole() {
  final role = App.getString("User Role");

  return role ?? "None";
}

String getAccountDataForAdmins() {
  final data = App.getString("Account Data For Admins");

  return data ?? "";
}

void setAccountDataForAdmins(String value) {
  App.setString("Account Data For Admins", value);
}

const allTimeMatchCacheKey = "Match JSONS";
const tempMatchCacheKey = "TEMP Match JSONS";

void addToMatchCache(String matchJSON) {
  App.setStringList(
    tempMatchCacheKey, 
    [
      ...(App.getStringList(tempMatchCacheKey) ?? []),
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
    allTimeMatchCacheKey, 
    <String>{...(App.getStringList(allTimeMatchCacheKey) ?? []), ...(App.getStringList(tempMatchCacheKey)!)}.toList(),
  );
}

List<String> getImmediateMatchCache() {
  return App.getStringList(tempMatchCacheKey) ?? [];
}

List<String> getAllTimeMatchCache() {
  return App.getStringList(allTimeMatchCacheKey) ?? [];
}

void confirmMatchMangled(String jsonStr, bool success) {
  final allTime = getAllTimeMatchCache().toSet();

  try {
    final json = jsonDecode(jsonStr);
    json["Mangled"] = !success;

    allTime.remove(jsonStr);
    allTime.add(jsonEncode(json));
  } catch (e) {
    // Do nothing...
    log("Captured exception while confirming matches: $e");
  }

  App.setStringList(allTimeMatchCacheKey, allTime.toList());
}

void resetImmediateMatchCache() {
  log("Resetting immediate match cache");
  App.setStringList(tempMatchCacheKey, []);
}

void resetAllTimeMatchCache() {
  log("Resetting all time match cache");
  App.setStringList(allTimeMatchCacheKey, []);
}

void resetMatchCache() {
  log("Resetting all match cache (all time and immediate)");
  App.setStringList(tempMatchCacheKey, []);
  App.setStringList(allTimeMatchCacheKey, []);
}