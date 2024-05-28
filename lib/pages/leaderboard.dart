import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:green_scout/utils/app_state.dart';
import 'package:green_scout/widgets/navigation_layout.dart';
import 'package:green_scout/utils/action_bar.dart';
import 'package:green_scout/widgets/header.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPage();
}

class RankingInfo {
  const RankingInfo(
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

      for (final personInfo in responseArray) {
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
      ),
      drawer: const NavigationLayoutDrawer(),
      body: ListView(
        children: [
          const Padding(padding: EdgeInsets.all(4)),
          const HeaderLabel("Leaderboard"),
          const Padding(padding: EdgeInsets.all(8)),
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

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: widthPadding),
        child: SizedBox(
          width: width,
          child: ExpansionTile(
            dense: true,

            leading: Text(
              (index + 1).toString(),
              style: Theme.of(context).textTheme.titleMedium,
            ),

            title: Text(
              info.displayName,
              style: Theme.of(context).textTheme.labelLarge,
            ),

            subtitle: Text(
              "${info.score} ${info.score > 1 ? "Points" : "Point"}",
              style: Theme.of(context).textTheme.labelMedium,
            ),

            // trailing: const Icon(Icons.badge),
            trailing: SizedBox(
              width: width * 0.40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  info.badges.containsKey("2024mnmi2")
                      ? Image.asset(
                          "assets/leaderboard/badges/st cloud mvp badge.png")
                      : const Padding(padding: EdgeInsets.zero),
                  getNumberedBadgeAsset(index) ??
                      const Padding(padding: EdgeInsets.zero),
                ],
              ),
            ),

            children: [
              Text("Username: ${info.username}"),
              info.badges.containsKey("2024mnmi2")
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        "[MVP] Scouted The Most During The St. Cloud Regional",
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    )
                  : const Padding(padding: EdgeInsets.zero),
            ],
          ),
        ),
      );
    }

    double widthRatio = 1.0;

    const ratioThresold = 460;

    {
      final width = MediaQuery.of(context).size.width;

      final percent =
          clampDouble(((width - ratioThresold) / (ratioThresold)), 0.0, 1.0);

      widthRatio = (1.0 - 0.55 * percent);
    }

    final width = MediaQuery.of(context).size.width * widthRatio;
    final widthPadding =
        MediaQuery.of(context).size.width * (1.0 - widthRatio) / 2;

    return SizedBox(
      width: width,
      height: MediaQuery.of(context).size.height * 0.8,
      child: ListView.builder(
        itemBuilder: (context, index) =>
            buildRankingEntry(context, index, rankings, width, widthPadding),
        itemCount: rankings.length,
      ),
    );
  }
}
