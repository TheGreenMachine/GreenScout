import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:green_scout/utils/achievement_manager.dart';
import 'package:green_scout/utils/app_state.dart';
import 'package:green_scout/utils/general_utils.dart';
import 'package:green_scout/widgets/navigation_layout.dart';
import 'package:green_scout/utils/action_bar.dart';
import 'package:green_scout/widgets/header.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPage();
}

class RankingInfo {
  RankingInfo(
    this.username,
    this.displayName,
    this.score,
    this.badges,
  );

  final String username;
  final String displayName;
  final int score;
  final Map<String, String> badges;
}

class _LeaderboardPage extends State<LeaderboardPage> {
  StreamController<List<RankingInfo>> rankingsController = StreamController();
  Stream<List<RankingInfo>> rankingsStream = const Stream.empty();

  @override
  void initState() {
    super.initState();

    App.httpGet('leaderboard', '', (response) {
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

        var info = (RankingInfo(personInfo["Username"],
            personInfo["DisplayName"], personInfo["Score"], badgeMap));

        rankings.add(info);
      }

      rankingsController.add(rankings);
    });

    rankingsStream = rankingsController.stream;
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
    );
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

      List<Widget> buildBadges(RankingInfo info, double size, bool capBadgesShowcased) {
        List<Widget> badges = [];
        for (var leaderboardBadge in AchievementManager.leaderboardBadges) {
          Widget badgeImage = leaderboardBadge.badge;
          String description = leaderboardBadge.description;
          if (leaderboardBadge.badge is Icon) {
            badgeImage = Icon(
              (leaderboardBadge.badge as Icon).icon,
            );
          }

          badges.add(SizedBox(
              width: size,
              height: size,
              child: Tooltip( 
                message: description,
                preferBelow: true,

                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  // width: size,
                  // height: size,
                  child: badgeImage,
                ))));
        }

        if (badges.length < 3 && capBadgesShowcased) {
          for (int i = 0; i < 3; i++) {
            badges.add(
              SizedBox(width: size, height: size,),
            );
          }
        }

        // Maybe this is a little too terse.
        return badges.sublist(0, capBadgesShowcased ? 3 : badges.length);
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
              padding: EdgeInsets.symmetric(horizontal: widthPadding, vertical: 50),
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(padding: EdgeInsets.all(6)),
                    Text(
                      info.displayName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
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

                color: Colors.grey.shade100,
              ),

              child: Row(
                children: [
                  const Padding(padding: EdgeInsets.all(6)),

                  Text(
                    (index + 1).toStringAsPrecision(3).replaceAll(".00", "   ").replaceAll(".0", "  "),
                    textAlign: TextAlign.start,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
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
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),

                  const Spacer(flex: 3,),

                  Text(
                    "${info.score} ${info.score > 1 ? "Points" : "Point"}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, fontStyle: FontStyle.italic),
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
