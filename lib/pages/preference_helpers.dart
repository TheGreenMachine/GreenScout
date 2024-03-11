
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