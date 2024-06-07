import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:green_scout/pages/admin/edit_users.dart';
import 'package:green_scout/pages/leaderboard.dart';
import 'package:green_scout/utils/app_state.dart';
import 'package:green_scout/utils/reference.dart';
import 'package:image_picker/image_picker.dart';

/// A class that pulls and updates data related to admin activities.
class AdminData {
  static const noActiveUserSelected =
      "[[CURRENTLY NO ACTIVE USER IS SELECTED AT THIS MOMENT]]";

  static StreamController<Map<String, String>> usersController =
      StreamController();

  static Map<String, String> users = {
    "None": noActiveUserSelected,
  };

  static Future<void> updateUserRoster() async {
    usersController = StreamController();
    users = {
      "None": noActiveUserSelected,
    };

    await App.httpRequest("allUsers", "", onGet: (response) {
      final respList = jsonDecode(response.body);

      respList.forEach((element) {
        Iterable<MapEntry> entries;
        entries = (element as Map).entries;

        users[entries.first.value] = entries.last.value;
      });

      usersController.add(users);
      usersController.done.then((value) {
        usersController.close();
      });
    });
  }

  static List<String> getDisplayNames() {
    return users.keys.toList();
  }

  static List<String> getUserIDs() {
    return users.values.toList();
  }

  static Future<bool> updateLeaderboardColor(
      LeaderboardColor newColor, UserInfo info) async {
    return App.httpRequest("/setColor", "", headers: {
      "Username": info.username,
      "uuid": info.uuid,
      "color": newColor.name,
    });
  }

  static Future<bool> updateDisplayName(
      String newDisplayName, UserInfo info) async {
    return App.httpRequest("/setDisplayName", "", headers: {
      "Username": info.username,
      "uuid": info.uuid,
      "displayName": newDisplayName,
    });
  }

  static Future<bool> updateUserPfp(XFile file, UserInfo info) async {
    return App.httpRequest("/setUserPfp", await file.readAsBytes(),
        headers: {"Username": info.username, "Filename": file.name});
  }

  static Future<UserInfo> adminGetUserInfo(String uuid) async {
    String displayName = "";
    LeaderboardColor color = LeaderboardColor.none;
    String username = "";
    List<String> badges = [];

    await App.httpRequest("/adminUserInfo", "", onGet: (response) {
      var responseJson = jsonDecode(response.body);

      displayName = responseJson["DisplayName"];
      username = responseJson["Username"];

      color = LeaderboardColor.values.elementAtOrNull(responseJson["Color"]) ??
          LeaderboardColor.none;

      for (var responseBadge in responseJson["Badges"]) {
        badges.add(responseBadge["ID"]);
      }
    }, headers: {"uuid": uuid});

    late Widget pfp;
    await App.httpRequest("getPfp", "", onGet: (response) {
      if (response.statusCode == 200) {
        pfp = Image.memory(response.bodyBytes);
      } else {
        pfp = const Icon(Icons.account_circle);
      }
    }, headers: {"username": username});

    return UserInfo(
        Reference(displayName), Reference(color), username, uuid, pfp,
        currentBadges: badges);
  }
}
