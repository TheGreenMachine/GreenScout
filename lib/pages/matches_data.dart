import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:green_scout/globals.dart';
import 'package:green_scout/pages/preference_helpers.dart';

class MatchInfo {
  const MatchInfo(this.matchNum, this.team, this.isBlue, this.driveTeamNum);

  final int matchNum;
  final int team;

  final bool isBlue;
  final int driveTeamNum;
}

class MatchesData {
  static List<MatchInfo> allParsedMatches = [];
  static List<MatchInfo> allAssignedMatches = [];

  @protected
  static String matchScheduleJsonKey = "Match Schedules";

  @protected
  static String assignedMatchScheduleJsonKey = "Assigned Matches Schedule";

  static void getAllMatchesFromServer() async {
    await App.httpGet("schedule", "", (response) {
      App.setString(matchScheduleJsonKey, response.body);
    });

    await App.httpGet("singleSchedule", getScouterName(), (response) {
      App.setString(assignedMatchScheduleJsonKey, response.body);
    });

    parseMatches();
  }

  static MapEntry<bool, int> toMatchInformation(int obfuscated) {
    bool isBlue = obfuscated > 3;
    int dsNum = (obfuscated - 1) % 3 + 1;
    return MapEntry(isBlue, dsNum);
  }

  static void parseMatches() {
    // This is currently some pre-filled data to test
    // if calling the "refresh button" does the proper
    // thing.

    String? scheduleJsonString = App.getString(matchScheduleJsonKey);
    String? assignedJsonString = App.getString(assignedMatchScheduleJsonKey);

    if (scheduleJsonString == null || scheduleJsonString == "") {
      return;
    }

    if (assignedJsonString == null || assignedJsonString == "") {
      return;
    }

    try {
      final scheduleJson =
          jsonDecode(scheduleJsonString) as Map<dynamic, dynamic>;

      allParsedMatches.clear();
      allAssignedMatches.clear();
      for (var entry in scheduleJson.entries) {
        final matchNum = int.parse(entry.key);
        allParsedMatches
            .add(MatchInfo(matchNum, entry.value["Blue"][0], true, 1));
        allParsedMatches
            .add(MatchInfo(matchNum, entry.value["Blue"][1], true, 2));
        allParsedMatches
            .add(MatchInfo(matchNum, entry.value["Blue"][2], true, 3));
        allParsedMatches
            .add(MatchInfo(matchNum, entry.value["Red"][0], false, 1));
        allParsedMatches
            .add(MatchInfo(matchNum, entry.value["Red"][1], false, 2));
        allParsedMatches
            .add(MatchInfo(matchNum, entry.value["Red"][2], false, 3));
      }

      Map<String, dynamic> assignedJson = jsonDecode(assignedJsonString);

      List<dynamic> ranges = assignedJson['Ranges'];

      List<List<int>> ranges2D = ranges.map((range) {
        return List<int>.from(range);
      }).toList();

      for (var range in ranges2D) {
        int beginning = range[0];
        int end = range[1];

        for (int i = beginning - 1; i < end; i++) {
          allAssignedMatches
              .add(allParsedMatches.elementAt(i * 6 - 1 + range[2] - 1));
        }
      }
    } catch (e) {
      log(e.toString());
    }
  }
}
