import 'package:flutter/material.dart';
import 'package:green_scout/utils/app_state.dart';
import 'package:green_scout/utils/main_app_data_helper.dart';
import 'package:green_scout/utils/reference.dart';

const cheat =
    true; //This is literally only here so i don't have an anyeurism while developing

//Why are these maps? No idea. I'm sure I had a good reason for it though. It could probably be done better as an enum, but i don't care enough.
class AchievementManager {
  static bool isCheating() {
    return cheat;
  }

  static Image gearEye = Image.asset(
    "assets/accolades/gearEye.png",
    width: 100,
    height: 100,
  );

  static var rudyHighlightsUnlocked = App.getBool("Foreign Fracas") ?? cheat;
  static var nazHighlightsUnlocked = cheat; //TODO spreadsheet
  static var routerGalleryUnlocked = cheat;

  static var displayNameUnlocked = cheat;
  static var profileChangeUnlocked = cheat;

  static var appThemesUnlocked = cheat;

  static var spreadsheetUnlocked = cheat;

  static var goldUnlocked = cheat;
  static var greenUnlocked = cheat;

  static final achievements = [
    PercentAchievement(
      "Scouting Rookie",
      "Scouted 1 match",
      gearEye,
      () => MainAppData.lifeScore / 1.0,
    ),
    PercentAchievement(
      "Scouting Novice",
      "Scouted 10 matches",
      const Icon(Icons.thumb_up_alt_sharp, size: 100),
      () => MainAppData.lifeScore / 10.0,
    ),
    PercentAchievement(
      "Scouter",
      "Scouted 50 matches",
      const Icon(Icons.school, size: 100),
      () => MainAppData.lifeScore / 50.0,
    ),
    PercentAchievement(
        "Scouting Pro",
        "Scouted 100 matches",
        const Icon(Icons.workspace_premium_sharp, size: 100),
        () => MainAppData.lifeScore / 100.0,
        unlocks: "App themes (Dark Mode!)",
        ref: Reference(appThemesUnlocked),
        setterKey: "Themes Unlocked"),
    PercentAchievement(
        "Scouting Enthusiast",
        "Scouted 500 matches",
        Image.asset("assets/accolades/goat.png",
            width: 100,
            height:
                100), // Loads a goat image for some reason. I don't know ask tag - Michael
        () => MainAppData.lifeScore / 500.0,
        unlocks: "Gold leaderboard name color",
        ref: Reference(goldUnlocked)),
    PercentAchievement("Locked In", "High Score of 50 matches",
        const Icon(Icons.lock, size: 100), () => MainAppData.highScore / 50.0,
        unlocks: "Display name changing", ref: Reference(displayNameUnlocked)),
    PercentAchievement("Déjà vu", "High score of 78 matches",
        const Icon(Icons.loop, size: 100), () => MainAppData.highScore / 78.0,
        unlocks: "Profile picture changing",
        ref: Reference(profileChangeUnlocked)),
    PercentAchievement("👀", "High score of 300 matches",
        const Icon(Icons.timer, size: 100), () => MainAppData.highScore / 300.0,
        unlocks: "Green leaderboard name color", ref: Reference(greenUnlocked)),
    Achievement(
      "Strategizer",
      "Opened the spreadsheet from the app",
      const Icon(Icons.grid_on, size: 100),
      unlocks: "Naz Reid highlights",
      isFrontendProvided: true,
      ref: Reference(nazHighlightsUnlocked),
    ),
    Achievement(
      "Foreign Fracas",
      "Opened the app while outside of the United States",
      const Icon(Icons.public, size: 100),
      unlocks: "Rudy Gobert highlights",
      isFrontendProvided: true,
      ref: Reference(rudyHighlightsUnlocked),
    ),
    Achievement(
      "Detective",
      "Changed the match layout",
      isFrontendProvided: true,
      const Icon(Icons.settings, size: 100),
    ),
    Achievement(
      "Debugger",
      "Opened the debug menu",
      isFrontendProvided: true,
      const Icon(Icons.developer_board, size: 100),
      met: App.getBool("Debugger") ?? cheat,
    ),
  ];

  // These are ordered by when they should appear on the leaderboard.

  static final leaderboardBadges = [
    Achievement(
      "Test",
      "This user is used for testing.",
      const Icon(Icons.smart_toy_outlined, size: 100),
    ),
    Achievement(
      "App Dev",
      "App Developer",
      const Icon(Icons.computer, size: 100),
      showDescription: false,
    ),
    Achievement(
      "Super Admin",
      "Super Administrator",
      const Icon(Icons.admin_panel_settings, size: 100),
      showDescription: false,
    ),
    Achievement(
      "HOF",
      "In the Hall of Fame",
      const Icon(Icons.emoji_events_sharp, size: 100),
    ),
    Achievement(
      "App Mentor",
      "App Mentor",
      Image.asset("assets/leaderboard/badges/gopher.png",
          width: 100, height: 100),
      showDescription: false,
    ),
    Achievement(
      "Captain",
      "Team Captain",
      const Icon(Icons.star, size: 100),
      showDescription: false,
    ),
    Achievement(
      "Admin",
      "Administrator",
      const Icon(Icons.admin_panel_settings_outlined, size: 100),
      showDescription: false,
    ),
    Achievement(
      "St Cloud MVP 2024",
      "Scouted the most matches during the 2024 Granite City Regional",
      Image.asset("assets/leaderboard/badges/st cloud mvp badge.png",
          width: 100, height: 100),
    ),
    Achievement(
      "Strategy Lead",
      "Strategy lead",
      Image.asset("assets/leaderboard/badges/sheets.png",
          width: 100, height: 100),
      showDescription: false,
    ),
    Achievement(
      "Assistant Captain",
      "Team Assistant Captain",
      const Icon(Icons.star_border, size: 100),
      showDescription: false,
    ),
    Achievement(
      "Mentor",
      "Mentor",
      const Icon(Icons.engineering, size: 100),
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
      "Leadership",
      "Leadership",
      const Icon(Icons.supervisor_account, size: 100),
      showDescription: false,
    ),
    Achievement(
      "CSP Lead",
      "CSP Lead",
      Image.asset("assets/leaderboard/badges/java.png",
          width: 100, height: 100),
      showDescription: false,
    ),
    Achievement(
      "Mechanical Lead",
      "Mechanical Lead",
      const Icon(Icons.build, size: 100),
      showDescription: false,
    ),
    Achievement(
      "Driveteam",
      "Member of the driveteam",
      const Icon(Icons.drive_eta, size: 100),
    ),
    Achievement(
      "Bug Finder",
      "Helped the devs find a bug",
      const Icon(Icons.bug_report, size: 100),
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
      ref: Reference(routerGalleryUnlocked),
    ),
    Achievement(
      "1816",
      "Member of Team 1816",
      gearEye,
      unlocks: "Spreadsheet link",
      ref: Reference(spreadsheetUnlocked),
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
    return achievements + leaderboardBadges + silentBadges;
  }

  static void syncAchievements(
      dynamic responseBadges, dynamic responseAccolades) {
    if (MainAppData.loggedIn) {
      Map<String, String> retrievedBadges = {};

      for (var responseBadge in responseBadges) {
        retrievedBadges[responseBadge["ID"]] = responseBadge["Description"];
      }

      for (var badge in leaderboardBadges) {
        if (retrievedBadges.keys.contains(badge.name)) {
          badge.met = true;
          if (badge.ref != null) {
            badge.ref!.value = true;
          }
          badge.showDescription = retrievedBadges[badge.name].toString() != "";

          badge.description = retrievedBadges[badge.name].toString();
        }
      }

      Map<String, bool> retrivedAccolades = {};
      List<Achievement> achivementsToNotify = [];

      for (var responseAccolade in responseAccolades) {
        retrivedAccolades[responseAccolade["Accolade"]] =
            responseAccolade["Notified"];
      }

      for (var achievement in achievements) {
        if ((retrivedAccolades).keys.contains(achievement.name)) {
          achievement.met = true;
          if (achievement.ref != null) {
            achievement.ref!.value = true;
          }
          if (!retrivedAccolades[achievement.name]! &&
              !achievement.isFrontendProvided) {
            achivementsToNotify.add(achievement);
          }

          if (achievement.setterKey != null) {
            App.setBool(achievement.setterKey!, true);
          }
        } else if (achievement.isFrontendProvided && achievement.met) {
          App.httpRequest("/provideAdditions",
              '{"UUID": "${MainAppData.userUUID}", "Achievements": ["${achievement.name}"]}');
        } else if (!cheat) {
          achievement.met = false;
          if (achievement.ref != null) {
            achievement.ref!.value = false;
          }
        }
      }

      if (achivementsToNotify.isNotEmpty) {
        MainAppData.notifyAchievementList(achivementsToNotify);
      }

      for (var silentBadge in silentBadges) {
        if ((retrivedAccolades).keys.contains(silentBadge.name)) {
          silentBadge.met = true;
          if (silentBadge.ref != null) {
            silentBadge.ref!.value = true;
          }
        }
      }
    }
  }
}

class Achievement {
  Achievement(this.name, this.description, this.badge,
      {this.met = cheat,
      this.unlocks,
      this.showDescription = true,
      this.ref,
      this.isFrontendProvided = false,
      this.setterKey});

  final String name;
  String description;
  final Widget badge;
  final String? unlocks;
  final Reference<bool>? ref;
  final String? setterKey;
  final bool isFrontendProvided;

  bool met;
  bool showDescription;
}

class PercentAchievement extends Achievement {
  PercentAchievement(
      super.name, super.description, super.badge, this.percentCompletion,
      {super.met = cheat,
      super.unlocks,
      super.showDescription = true,
      super.ref,
      super.setterKey});

  double Function() percentCompletion;
}
