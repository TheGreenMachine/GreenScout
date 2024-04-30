import 'dart:developer';

import 'package:green_scout/utils/app_state.dart';
import 'package:green_scout/pages/preference_helpers.dart';
import 'package:http/http.dart' as http;

class AdminAllAccounts {
  List<AccountAdminInfo> accounts = [];

  static void load() {
    if (isAdmin()) {
      final path =
          Uri(scheme: 'https', host: serverHostName, path: '', port: 443);

      http.post(path, headers: {}).then((response) {
        log("Response status: ${response.statusCode}");
        log("Response body: ${response.body}");

        setAccountDataForAdmins(response.body);
      }).catchError((error) {
        log(error.toString());
      });
    }
  }
}

class AccountAdminInfo {
  const AccountAdminInfo(this.displayName, this.uuid);

  final String displayName;
  final String uuid;
}
