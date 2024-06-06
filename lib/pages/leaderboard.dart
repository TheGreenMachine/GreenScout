import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:green_scout/utils/achievement_manager.dart';
import 'package:green_scout/utils/app_state.dart';
import 'package:green_scout/utils/general_utils.dart';
import 'package:green_scout/widgets/header.dart';
import 'package:green_scout/widgets/navigation_layout.dart';
import 'package:green_scout/utils/action_bar.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPage();
}

enum LeaderboardColor {
  none,
  green,
  gold;

  Color get colorValue {
    return switch (this) {
      LeaderboardColor.none => Colors.black,
      LeaderboardColor.gold => Colors.amber,
      LeaderboardColor.green => greenMachineGreen
    };
  }

  static LeaderboardColor fromString(String str) {
    switch (str) {
      case "gold":
        return gold;
      case "green":
        return green;
      default:
        return none;
    }
  }

  static Map<String, LeaderboardColor> getUnlockedColors() {
    var colorsToReturn = {none.name: none};
    if (AchievementManager.greenUnlocked.value) {
      colorsToReturn[green.name] = green;
    }

    if (AchievementManager.goldUnlocked.value) {
      colorsToReturn[gold.name] = gold;
    }

    return colorsToReturn;
  }
}

// ignore: constant_identifier_names
enum LeaderboardType { Score, HighScore, LifeScore }

class RankingInfo {
  RankingInfo(this.username, this.displayName, this.score, this.badges,
      this.leaderboardColor)
      : this.leaderboardColorValue = leaderboardColor.colorValue;

  final String username;
  final String displayName;
  final int score;
  final LeaderboardColor leaderboardColor;
  final Map<String, String> badges;
  Color leaderboardColorValue;
}

class _LeaderboardPage extends State<LeaderboardPage> {
  StreamController<List<RankingInfo>> rankingsController = StreamController();
  Stream<List<RankingInfo>> rankingsStream = const Stream.empty();

  @override
  void initState() {
    super.initState();

    App.httpRequest('leaderboard', '', onGet: (response) {
      final responseJson = jsonDecode(response.body);

      final responseArray = responseJson as List<dynamic>;
      List<RankingInfo> rankings = [];
      for (int i = 0; i < responseArray.length; i++) {
        var personInfo = responseArray[i];
        Map<String, String> badgeMap = {};

        for (var badge in personInfo["Badges"]) {
          Map<String, String> asMap = Map.from(badge);
          badgeMap[asMap["ID"]!] = asMap["Description"]!;
        }

        var info = (RankingInfo(
            personInfo["Username"],
            personInfo["DisplayName"],
            personInfo["Score"],
            badgeMap,
            LeaderboardColor.values.elementAtOrNull(personInfo["Color"]) ??
                LeaderboardColor.none));

        if (info.score != 0) {
          rankings.add(info);
        }
      }

      rankingsController.add(rankings);
    }, headers: {"type": LeaderboardType.Score.name});

    rankingsStream = rankingsController.stream;
  }

  void switchParameters(LeaderboardType type) {
    App.httpRequest('leaderboard', '', onGet: (response) {
      final responseJson = jsonDecode(response.body);

      final responseArray = responseJson as List<dynamic>;
      List<RankingInfo> rankings = [];
      for (int i = 0; i < responseArray.length; i++) {
        var personInfo = responseArray[i];
        Map<String, String> badgeMap = {};

        for (var badge in personInfo["Badges"]) {
          Map<String, String> asMap = Map.from(badge);
          badgeMap[asMap["ID"]!] = asMap["Description"]!;
        }

        var info = (RankingInfo(
            personInfo["Username"],
            personInfo["DisplayName"],
            personInfo[type.name],
            badgeMap,
            LeaderboardColor.values.elementAtOrNull(personInfo["Color"]) ??
                LeaderboardColor.none));

        if (info.score != 0) {
          rankings.add(info);
        }
      }

      rankingsController.add(rankings);
    }, headers: {"type": type.name});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: createDefaultActionBar(),
          title: const Text(
            "Leaderboard",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        drawer: const NavigationLayoutDrawer(),
        body: ListView(
          children: [
            StreamBuilder(
              stream: rankingsStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return buildRankingsList(context, snapshot.requireData);
                }

                return buildUnloadedLeaderboard(context);
              },
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FittedBox(
                fit: BoxFit.contain,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () => switchParameters(LeaderboardType.Score),
                      child: const Text('Score'),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          switchParameters(LeaderboardType.HighScore),
                      child: const Text('High Score'),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          switchParameters(LeaderboardType.LifeScore),
                      child: const Text('Lifetime Score'),
                    ),
                  ],
                )),
          ),
        ));
  }

  Widget buildFailedLoad(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Text(
        "Unable To Load Leaderboards\n:(",
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.displaySmall,
      ),
    );
  }

  Widget buildUnloadedLeaderboard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 40),
      child: Text(
        "Loading Leaderboards...",
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.displaySmall,
      ),
    );
  }

  Widget buildRankingsList(BuildContext context, List<RankingInfo> rankings) {
    Widget buildRankingEntry(BuildContext context, int index,
        List<RankingInfo> rankings, double width, double widthPadding) {
      final info = rankings[index];

      Image? getNumberedBadgeAsset(int index) {
        switch (index) {
          case 0:
            return Image.asset("assets/leaderboard/badges/1st place badge.png");

          case 1:
            return Image.asset("assets/leaderboard/badges/2nd place badge.png");

          case 2:
            return Image.asset("assets/leaderboard/badges/3rd place badge.png");
        }

        return null;
      }

      List<Widget> buildBadges(
          RankingInfo info, double size, bool capBadgesShowcased) {
        List<Widget> badges = [];
        for (var leaderboardBadge in AchievementManager.leaderboardBadges) {
          if (info.badges.keys.contains(leaderboardBadge.name)) {
            Widget badgeImage = leaderboardBadge.badge;
            String description = leaderboardBadge.description;
            if (leaderboardBadge.badge is Icon) {
              badgeImage = Icon(
                (leaderboardBadge.badge as Icon).icon,
              );
            }

            String message = leaderboardBadge.name;
            if (info.badges[leaderboardBadge.name]! != "") {
              description = info.badges[leaderboardBadge.name]!;
              message = "${leaderboardBadge.name}: $description";
            }

            badges.add(SizedBox(
                width: size,
                height: size,
                child: Tooltip(
                    message: message,
                    preferBelow: true,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      // width: size,
                      // height: size,
                      child: badgeImage,
                    ))));
          }
        }

        // Maybe this is a little too terse.
        if (badges.isNotEmpty) {
          int cap = 3;
          if (badges.length < cap) {
            cap = badges.length;
          }

          return badges.sublist(0, capBadgesShowcased ? cap : badges.length);
        }
        return [const SizedBox()];
      }

      void showInfoPopup(
        BuildContext context,
        RankingInfo info,
        double width,
        double widthPadding,
      ) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: widthPadding, vertical: 50),
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(padding: EdgeInsets.all(6)),
                    Text(
                      info.displayName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          color: info.leaderboardColorValue),
                    ),
                    Text(
                      info.username,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                      ),
                    ),
                    const Padding(padding: EdgeInsets.all(2)),
                    Text(
                      "${info.score} ${info.score > 1 ? "Points" : "Point"}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        // fontStyle: FontStyle.italic,
                      ),
                    ),
                    const Padding(padding: EdgeInsets.all(20)),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: width / 4,
                      ),
                      child: App.getProfileImage(info.username),
                    ),
                    const Padding(padding: EdgeInsets.all(16)),
                    Flexible(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        clipBehavior: Clip.antiAlias,
                        alignment: WrapAlignment.center,
                        children: buildBadges(info, width * 0.15, false),
                      ),
                    ),
                    const Padding(padding: EdgeInsets.all(16)),
                  ],
                ),
              ),
            );
          },
        );
      }

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: widthPadding, vertical: 4),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: width * 0.05,
            minHeight: width * 0.02,
          ),
          child: InkWell(
            onTap: () {
              showInfoPopup(context, info, width, widthPadding);
            },
            child: Ink(
              width: width,
              height: 65,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                color: App.getThemeMode() == Brightness.light
                    ? Colors.grey.shade100
                    : Colors.grey.shade600,
              ),
              child: Row(
                children: [
                  const Padding(padding: EdgeInsets.all(6)),
                  Text(
                    (index + 1)
                        .toStringAsPrecision(3)
                        .replaceAll(".00", "   ")
                        .replaceAll(".0", "  "),
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                  const Padding(padding: EdgeInsets.all(10)),
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: App.getProfileImage(info.username),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.all(6)),
                  Flexible(
                    flex: 8,
                    fit: FlexFit.tight,
                    child: Text(
                      info.displayName,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: info.leaderboardColorValue),
                    ),
                  ),
                  const Spacer(
                    flex: 3,
                  ),
                  Text(
                    "${info.score} ${info.score > 1 ? "Points" : "Point"}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        fontStyle: FontStyle.italic),
                  ),
                  const Padding(padding: EdgeInsets.all(12)),
                  ...buildBadges(info, width * 0.04, true),
                  const Padding(padding: EdgeInsets.all(10)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final (width, widthPadding) = screenScaler(
      MediaQuery.of(context).size.width,
      460,
      0.45,
      1.0,
    );

    if (rankings.isEmpty) {
      return SizedBox(
          width: width,
          height: MediaQuery.of(context).size.height * 0.92,
          child: const HeaderLabel("No entries!"));
    }

    return SizedBox(
      width: width,
      height: MediaQuery.of(context).size.height * 0.92,
      child: ListView.builder(
        itemBuilder: (context, index) =>
            buildRankingEntry(context, index, rankings, width, widthPadding),
        itemCount: rankings.length,
        clipBehavior: Clip.antiAlias,
      ),
    );
  }
}
