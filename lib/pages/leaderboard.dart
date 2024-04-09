import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:green_scout/pages/navigation_layout.dart';
import 'package:green_scout/widgets/action_bar.dart';
import 'package:green_scout/widgets/header.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPage();
} 

class RankingInfo {
  
}

class _LeaderboardPage extends State<LeaderboardPage> {
  StreamController<List<RankingInfo>> rankingsController = StreamController();
  Stream<List<RankingInfo>> rankingsStream = const Stream.empty();

  @override
  void initState() {
    super.initState();

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

          buildRankingsList(context, [RankingInfo(), RankingInfo()]),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Text("Leaderboards are currently a work in progress. This feature will most likely not be finished until we have successfully made sure that all the core features are functional.", textAlign: TextAlign.center,),
          ),
        ],
      ),
    );
  }

  Widget buildRankingsList(BuildContext context, List<RankingInfo> rankings) {
    Widget buildRankingEntry(BuildContext context, int index, List<RankingInfo> rankings, double width, double widthPadding) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: widthPadding),

        child: SizedBox(
          width: width,

          child: Text("Helllo"),
        ),
      );
    }

    double widthRatio = 1.0;

    const ratioThresold = 670;

    {
      final width = MediaQuery.of(context).size.width;

      final percent = clampDouble(((width - ratioThresold) / (ratioThresold)), 0.0, 1.0);

      widthRatio = (1.0 - 0.75 * percent);
    }

    final width = MediaQuery.of(context).size.width * widthRatio;
    final widthPadding = MediaQuery.of(context).size.width * (1.0 - widthRatio) / 2;

    return SizedBox(
      width: width,
      height: 500,

      child: ListView.builder(
        itemBuilder: (context, index) => buildRankingEntry(context, index, rankings, width, widthPadding),
        itemCount: rankings.length,
      ),
    );
  }
}