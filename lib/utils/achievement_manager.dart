import 'package:flutter/material.dart';
import 'package:green_scout/utils/app_state.dart';
import 'package:green_scout/utils/main_app_data_helper.dart';

const cheat =
    true; //This is literally only here so i don't have an anyeurism while developing

Image gearEye = Image.asset(
  "accolades/gearEye.png",
  width: 100,
  height: 100,
);

Image goat = Image.asset(
  "accolades/goat.png",
  width: 100,
  height: 100,
);

//Why are these maps? No idea. I'm sure I had a good reason for it though.
class AchievementManager {
  var achievements = {
    "Scouting Rookie": PercentAchievement(
      "Scouting Rookie",
      "Scouted 1 match",
      gearEye,
      () => MainAppData.lifeScore / 1,
    ),
    "Scouting Novice": PercentAchievement(
        "Scouting Novice",
        "Scouted 10 matches",
        const Icon(Icons.thumb_up_alt_sharp, size: 100),
        () => MainAppData.lifeScore / 10),
    "Scouter": PercentAchievement("Scouter", "Scouted 50 matches",
        const Icon(Icons.school, size: 100), () => MainAppData.lifeScore / 50),
    "Scouting Pro": PercentAchievement(
        "Scouting Pro",
        "Scouted 100 matches",
        const Icon(Icons.workspace_premium_sharp, size: 100),
        () => MainAppData.lifeScore / 100),
    "Scouting Enthusiast": PercentAchievement("Scouting Enthusiast",
        "Scouted 500 matches", goat, () => MainAppData.lifeScore / 500),
    "Locked In": PercentAchievement("Locked In", "High Score of 50 matches",
        const Icon(Icons.lock, size: 100), () => MainAppData.highScore / 50),
    "Déjà vu": PercentAchievement("Déjà vu", "High score of 78 matches",
        const Icon(Icons.loop, size: 100), () => MainAppData.highScore / 78),
    "👀": PercentAchievement("👀", "High score of 300 matches",
        const Icon(Icons.timer, size: 100), () => MainAppData.highScore / 300),
    "Strategizer": Achievement(
      "Strategizer",
      "Opened the spreadsheet from the app",
      const Icon(Icons.grid_on, size: 100),
    ),
    "Foreign Fracas": Achievement(
        "Foreign Fracas",
        "Opened the app while outside of the united states",
        const Icon(Icons.public, size: 100)),
    "Detective": Achievement("Detective", "Changed the match layout",
        const Icon(Icons.settings, size: 100)),
    "Debugger": Achievement("Debugger", "Opened the debug menu",
        const Icon(Icons.developer_board, size: 100)),
    "Router": Achievement(
        "Router Dungeon Survivor",
        "Survived the router dungeon",
        Image.asset("accolades/ryanMcgoff.png", width: 100, height: 100)),
  };

  var leaderboardBadges = {
    "Mvp_2024mnmi2": Achievement(
        "St Cloud MVP 2024",
        "Scouted the most matches during the 2024 Granite City Regional",
        Image.asset("assets/leaderboard/badges/st cloud mvp badge.png",
            width: 100, height: 100)),
    "Developer": Achievement(
        "Developer", "App Developer", const Icon(Icons.computer, size: 100)),
    "Frontend_Dev": Achievement(
        "Frontend Dev", "Frontend Developer", const FlutterLogo(size: 100)),
    "Backend_Dev": Achievement("Backend Dev", "Backend Developer",
        Image.asset("leaderboard/badges/go.png", width: 100, height: 100)),
    "Strategy Lead": Achievement("Strategy Lead", "Strategy lead",
        Image.asset("leaderboard/badges/sheets.png", width: 100, height: 100)),
    "Leadership": Achievement("Leadership", "Leadership",
        const Icon(Icons.supervisor_account, size: 100)),
    "Captain": Achievement(
        "Captain", "Team Captain", const Icon(Icons.star, size: 100)),
    "Assistant_Captain": Achievement("Assistant Captain",
        "Team Assistant Captain", const Icon(Icons.star_border, size: 100)),
    "CSP_Lead": Achievement("CSP Lead", "CSP Lead",
        Image.asset("leaderboard/badges/java.png", width: 100, height: 100)),
    "Mech_Lead": Achievement("Mechanical Lead", "Mechanical Lead",
        const Icon(Icons.build, size: 100)),
    "Mentor": Achievement(
        "Mentor", "Mentor", const Icon(Icons.engineering, size: 100)),
    "App_Mentor": Achievement("App Mentor", "App Mentor",
        Image.asset("leaderboard/badges/gopher.png", width: 100, height: 100)),
    "Admin": Achievement("Admin", "Administrator",
        const Icon(Icons.admin_panel_settings_outlined, size: 100)),
    "SuperAdmin": Achievement("SuperAdmin", "Super Administrator",
        const Icon(Icons.admin_panel_settings, size: 100)),
    "Test": Achievement("Test", "This user is used for testing.",
        const Icon(Icons.smart_toy_outlined, size: 100)),
    "Driveteam": Achievement("Driveteam", "Member of the driveteam",
        const Icon(Icons.drive_eta, size: 100)),
    "HOF": Achievement("HOF", "In the Hall of Fame",
        const Icon(Icons.emoji_events_sharp, size: 100)),
    "Bug_Finder": Achievement("Bug Finder", "Helped the devs find a bug",
        const Icon(Icons.bug_report, size: 100)),
  };

  var textBadges = {
    "1816": Achievement(
        "1816", "Member of FRC Team 1816, \"The Green Machine\"", gearEye),
  };

  var silentBadges = {
    "Early": Achievement(
        "Early adopter",
        "Used the app during the 2024 Crescendo season",
        Image.asset("accolades/note.png", width: 100, height: 100)),
  };

  double getCompletionRatio() {
    int numMet = 0;
    for (var element in achievements.values) {
      if (element.met) {
        numMet++;
      }
    }
    return (numMet / achievements.length);
  }

  void checkUpdatePool() async {
    await App.httpGet(
        "/updates", "", (result) {}, {"username": MainAppData.scouterName});
  }
}

class Achievement {
  Achievement(this.name, this.description, this.badge, {this.met = cheat});

  final String name;
  String description;
  final Widget badge;

  bool met;
}

class PercentAchievement extends Achievement {
  PercentAchievement(
      super.name, super.description, super.badge, this.percentCompletion,
      {super.met = false});
  double Function() percentCompletion;
}
