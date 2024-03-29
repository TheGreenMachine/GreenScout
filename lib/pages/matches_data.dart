import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:green_scout/globals.dart';

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

	static void getAllMatchesFromServer() {
		final scheduleResult = App.httpGet("schedule");

		if (scheduleResult != null) {
			App.setString(matchScheduleJsonKey, scheduleResult);
		}

		final assignedResult = App.httpGet("singleSchedule");

		if (assignedResult != null) {
			App.setString(assignedMatchScheduleJsonKey, assignedResult);
		}

		parseMatches();
	}

	static void parseMatches() {
		String? scheduleJsonString = App.getString(matchScheduleJsonKey);
		String? assignedJsonString = App.getString(assignedMatchScheduleJsonKey);

		if (scheduleJsonString == null) {
			return;
		}

		if (assignedJsonString == null) {
			return;
		}

		if (scheduleJsonString != "") {
			return;
		}

		if (assignedJsonString != "") {
			return;
		} 

		try {
			allParsedMatches.addAll(
				[
					const MatchInfo(1, 1816, false, 1),
					const MatchInfo(1, 2502, false, 2),
					const MatchInfo(1, 2525, false, 3),
					const MatchInfo(1, 3021, true, 1),
					const MatchInfo(1, 12, true, 2),
					const MatchInfo(1, 19020, true, 3),
				]
			);

			allAssignedMatches.addAll(
				allParsedMatches.sublist(3),
			);

			final scheduleJson = jsonDecode(scheduleJsonString);
			final assignedJson = jsonDecode(assignedJsonString);
		} catch (e) {
			log(e.toString());
		}
	}
}