import '../globals.dart';

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

const matchCacheKey = "Match JSONS";

List<String> matchCache = [];

void addToMatchCache(String matchJSON) {
  matchCache.add(matchJSON);
}

List<String> getMatchCache() {
  return matchCache;
}

void resetMatchCache() {
  print("Resetting cache");
  matchCache = [];
}
