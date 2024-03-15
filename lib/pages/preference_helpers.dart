
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

String getAccountDataForAdmins() {
	final data = App.getString("Account Data For Admins");

	return data ?? "";
}

void setAccountDataForAdmins(String value) {
	App.setString("Account Data For Admins", value);
}

const matchCacheKey = "Match JSONS";

void addToMatchCache(String matchJSON) {
	var matches = App.getStringList(matchCacheKey) ?? [];

	matches.add(matchJSON);

	App.setStringList(matchCacheKey, matches);
}

List<String> getMatchCache() {
	return App.getStringList(matchCacheKey) ?? [];
}

void resetMatchCache() {
	App.setStringList(matchCacheKey, []);
}