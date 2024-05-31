import 'package:flutter/material.dart';
import 'package:green_scout/utils/app_state.dart';
import 'package:green_scout/utils/main_app_data_helper.dart';

const cheat =
    true; //This is literally only here so i don't have an anyeurism while developing

//Why are these maps? No idea. I'm sure I had a good reason for it though. It could probably be done better as an enum, but i don't care enough.
class AchievementManager {
  static Image gearEye = Image.asset(
    "assets/accolades/gearEye.png",
    width: 100,
    height: 100,
  );

  static var rudyHighlightsUnlocked = false;
  static var nazHighlightsUnlocked = false;
  static var routerGalleryUnlocked = false;

  static var displayNameUnlocked = false;
  static var profileChangeUnlocked = false;

  static final achievements = [
    PercentAchievement(
      "Scouting Rookie",
      "Scouted 1 match",
      gearEye,
      () => MainAppData.lifeScore / 1,
    ),

    PercentAchievement(
      "Scouting Novice",
      "Scouted 10 matches",
      const Icon(Icons.thumb_up_alt_sharp, size: 100),
      () => MainAppData.lifeScore / 10,
    ),

    PercentAchievement(
      "Scouter", 
      "Scouted 50 matches",
      const Icon(Icons.school, size: 100), 
      () => MainAppData.lifeScore / 50,
    ),

    PercentAchievement(
      "Scouting Pro",
      "Scouted 100 matches",
      const Icon(Icons.workspace_premium_sharp, size: 100),
      () => MainAppData.lifeScore / 100,
      unlocks: "App themes",
    ),

    PercentAchievement(
      "Scouting Enthusiast",
      "Scouted 500 matches", 
      Image.asset("assets/accolades/goat.png", width: 100, height: 100), // Loads a goat image for some reason. I don't know ask tag - Michael
      () => MainAppData.lifeScore / 500,
      unlocks: "Gold leaderboard name color",
    ),

    PercentAchievement(
      "Locked In",
      "High Score of 50 matches",
      const Icon(Icons.lock, size: 100),
      () => MainAppData.highScore / 50,
      unlocks: "Display name changing",
      conditionMet: (value) => displayNameUnlocked = value,
    ),

    PercentAchievement(
      "Déjà vu",
      "High score of 78 matches",
      const Icon(Icons.loop, size: 100),
      () => MainAppData.highScore / 78,
      unlocks: "Profile picture changing",
      conditionMet: (value) => profileChangeUnlocked = value,
    ),

    PercentAchievement(
      "👀", 
      "High score of 300 matches",
      const Icon(Icons.timer, size: 100), 
      () => MainAppData.highScore / 300,
      unlocks: "Green leaderboard name color",
    ),

    Achievement(
      "Strategizer",
      "Opened the spreadsheet from the app",
      const Icon(Icons.grid_on, size: 100),
      unlocks: "Naz Reid highlights",
      conditionMet: (value) => nazHighlightsUnlocked = value,
    ),

    Achievement(
      "Foreign Fracas",
      "Opened the app while outside of the United States",
      const Icon(Icons.public, size: 100),
      unlocks: "Rudy Gobert highlights",
      conditionMet: (value) => rudyHighlightsUnlocked = value,
    ),

    Achievement(
      "Detective", 
      "Changed the match layout",
      const Icon(Icons.settings, size: 100),
    ),

    Achievement(
      "Debugger", 
      "Opened the debug menu",
      const Icon(Icons.developer_board, size: 100),
    ),
  ];

  static final leaderboardBadges = [
    Achievement(
      "St Cloud MVP 2024",
      "Scouted the most matches during the 2024 Granite City Regional",
      Image.asset("assets/leaderboard/badges/st cloud mvp badge.png", width: 100, height: 100), 
    ),

    Achievement(
      "App Dev", 
      "App Developer", 
      const Icon(Icons.computer, size: 100),
      showDescription: false,
    ),

    Achievement(
      "Frontend Dev", 
      "Frontend Developer", 
      const FlutterLogo(size: 100),
      showDescription: false,
    ),

    Achievement(
      "Backend Dev", 
      "Backend Developer",
      Image.asset("assets/leaderboard/badges/go.png", width: 100, height: 100),
      showDescription: false,
    ),

    Achievement(
      "Strategy Lead", 
      "Strategy lead",
      Image.asset("assets/leaderboard/badges/sheets.png", width: 100, height: 100),
      showDescription: false,
    ),

    Achievement(
      "Leadership", 
      "Leadership",
      const Icon(Icons.supervisor_account, size: 100),
      showDescription: false,
    ),

    Achievement(
      "Captain", 
      "Team Captain", 
      const Icon(Icons.star, size: 100),
      showDescription: false,
    ),

    Achievement(
      "Assistant Captain",
      "Team Assistant Captain", 
      const Icon(Icons.star_border, size: 100),
      showDescription: false,
    ),

    Achievement(
      "CSP Lead", 
      "CSP Lead",
      Image.asset("assets/leaderboard/badges/java.png", width: 100, height: 100),
      showDescription: false,
    ),

    Achievement(
      "Mechanical Lead", 
      "Mechanical Lead",
      const Icon(Icons.build, size: 100),
      showDescription: false,
    ),
    
    Achievement(
      "Mentor", 
      "Mentor", 
      const Icon(Icons.engineering, size: 100),
      showDescription: false,
    ),

    Achievement(
      "App Mentor", 
      "App Mentor",
      Image.asset("assets/leaderboard/badges/gopher.png", width: 100, height: 100),
      showDescription: false,
    ),

    Achievement(
      "Admin", 
      "Administrator",
      const Icon(Icons.admin_panel_settings_outlined, size: 100),
      showDescription: false,
    ),

    Achievement(
      "Super Admin", 
      "Super Administrator",
      const Icon(Icons.admin_panel_settings, size: 100),
      showDescription: false,
    ),

    Achievement(
      "Test", 
      "This user is used for testing.",
      const Icon(Icons.smart_toy_outlined, size: 100),
    ),

    Achievement(
      "Driveteam", 
      "Member of the driveteam",
      const Icon(Icons.drive_eta, size: 100),
    ),

    Achievement(
      "HOF", 
      "In the Hall of Fame",
      const Icon(Icons.emoji_events_sharp, size: 100),
    ),

    Achievement(
      "Bug Finder", 
      "Helped the devs find a bug",
      const Icon(Icons.bug_report, size: 100),
    ),
  ];

  static final textBadges = [
    Achievement(
      "1816", 
      "Member of Team 1816", 
      gearEye,
      unlocks: "Spreadsheet link",
    ),
  ];

  static final silentBadges = [
    Achievement(
      "Early adopter",
      "Used the app during the 2024 Crescendo season",
      Image.asset("assets/accolades/note.png", width: 100, height: 100),
    ),

    Achievement(
      "Router Dungeon Survivor",
      "Survived the router dungeon",
      Image.asset("assets/accolades/ryanMcgoff.png", width: 100, height: 100),
      unlocks: "Ryan McGoff photo gallery",
      conditionMet: (value) => routerGalleryUnlocked = value,
    ),
  ];

  static double getCompletionRatio() {
    int numMet = 0;

    for (var element in achievements) {
      if (element.met) {
        numMet++;
      }
    }

    return (numMet / achievements.length);
  }

  static List<Achievement> allAchievements() {
    return achievements + leaderboardBadges + textBadges + silentBadges;
  }

  void checkUpdatePool() async {
    await App.httpGet(
        "/updates", "", (result) {}, {"username": MainAppData.scouterName});
  }
}

class Achievement {
  Achievement(
    this.name, 
    this.description, 
    this.badge,
    {
      this.met = cheat, 
      this.conditionMet,
      this.unlocks, 
      this.showDescription = true,
    }
  );

  final String name;
  String description;
  final Widget badge;
  final String? unlocks;

  void Function(bool)? conditionMet;
  bool met;
  bool showDescription;
}

class PercentAchievement extends Achievement {
  PercentAchievement(
    super.name, 
    super.description, 
    super.badge, 
    this.percentCompletion,
    {
      super.met = cheat, 
      super.conditionMet,
      super.unlocks,
      super.showDescription = true,
    }
  );

  double Function() percentCompletion;
}
