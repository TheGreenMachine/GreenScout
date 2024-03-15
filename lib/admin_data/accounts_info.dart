import 'dart:developer';

import 'package:GreenScout/globals.dart';
import 'package:GreenScout/pages/preference_helpers.dart';
import 'package:http/http.dart' as http;

class AdminAllAccounts {
	List<AccountAdminInfo> accounts = []; 

	static void load() {
		if (isAdmin()) {
			final path = Uri(scheme: 'http', host: serverHostName, path: '', port: 3333);

			http.post(path, headers: {}).then((response) {
				log("Response status: ${response.statusCode}");
				log("Response body: ${response.body}");

				setAccountDataForAdmins(response.body);
			}).catchError((error) { log(error.toString()); });
		}
	}
}

class AccountAdminInfo {
	const AccountAdminInfo(this.displayName, this.uuid);

	final String displayName;
	final String uuid;
}