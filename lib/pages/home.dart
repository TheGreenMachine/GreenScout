import 'package:green_scout/utils/achievement_manager.dart';
import 'package:green_scout/utils/app_state.dart';
import 'package:green_scout/pages/admin.dart';
import 'package:green_scout/pages/match_form.dart';
import 'package:green_scout/widgets/navigation_layout.dart';
import 'package:green_scout/utils/main_app_data_helper.dart';
import 'package:green_scout/utils/action_bar.dart';
import 'package:green_scout/widgets/floating_button.dart';
import 'package:flutter/material.dart';
import 'package:green_scout/widgets/header.dart';
import 'package:green_scout/widgets/subheader.dart';

import '../utils/matches_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  List<Widget> createAdminPageButton(BuildContext context) {
    if (!MainAppData.isAdmin) {
      return [];
    }

    return [
      const Padding(padding: EdgeInsets.all(4)),
      const SubheaderLabel("Admin Page"),
      const Padding(padding: EdgeInsets.all(2)),
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * (1.0 - 0.75),
          vertical: 2,
        ),
        child: FloatingButton(
          icon: const Icon(Icons.admin_panel_settings),
          color: Theme.of(context).colorScheme.primaryContainer.withBlue(255),
          onPressed: () => App.gotoPage(context, const AdminPage()),
        ),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      MatchesData.parseMatches();

      if (!AchievementManager.rudyHighlightsUnlocked) {
        MainAppData.checkIpForeign(context);
      }
    });
  }

  List<Widget> createMatchFormPageButton(BuildContext context) {
    return [
      const SubheaderLabel("Create New Match Form"),
      const Padding(padding: EdgeInsets.all(2)),
      Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * (1.0 - 0.75)),
        child: FloatingButton(
          icon: const Icon(Icons.create),
          color: Theme.of(context).colorScheme.inversePrimary,
          onPressed: () => App.gotoPage(context, const MatchFormPage()),
        ),
      ),
    ];
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
          ...createAdminPageButton(context),
          const Padding(padding: EdgeInsets.all(15)),
          ...createMatchFormPageButton(context),
          const Padding(padding: EdgeInsets.all(18)),
          const HeaderLabel("Assigned Matches"),
          const Padding(padding: EdgeInsets.all(4)),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85)),
            child: SizedBox(
              height: 250,
              child: ListView.builder(
                itemBuilder: (context, index) => matchViewBuilder(
                    context, index, MatchesData.allAssignedMatches),
                itemCount: MatchesData.allAssignedMatches.length,
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.all(12)),
          const HeaderLabel("All Matches"),
          const Padding(padding: EdgeInsets.all(4)),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85)),
            child: SizedBox(
              height: 250,
              child: ListView.builder(
                itemBuilder: (context, index) => matchViewBuilder(
                    context, index, MatchesData.allParsedMatches),
                itemCount: MatchesData.allParsedMatches.length,
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.all(16)),
        ],
      ),
      floatingActionButton: FloatingButton(
        icon: const Icon(Icons.refresh),
        color: Theme.of(context).colorScheme.inversePrimary,
        onPressed: () {
          MatchesData.getAllMatchesFromServer();
          // sleep(Durations.medium3);
          setState(() {});
        },
      ),
    );
  }

  Widget matchViewBuilder(
      BuildContext context, int index, List<MatchInfo> matches) {
    final match = matches[index];

    return ExpansionTile(
      leading: Text("${match.matchNum}${match.isBlue ? "B" : "R"}"),
      title: Text(match.team.toString()),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.5)),
      collapsedShape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.5)),

      backgroundColor: match.isBlue
          ? Theme.of(context).colorScheme.inversePrimary.withBlue(255)
          : Theme.of(context).colorScheme.inversePrimary.withRed(255),

      collapsedBackgroundColor: match.isBlue
          ? Theme.of(context).colorScheme.inversePrimary.withBlue(255)
          : Theme.of(context).colorScheme.inversePrimary.withRed(255),

      // textColor: Theme.of(context).colorScheme.surface,
      // collapsedTextColor: Theme.of(context).colorScheme.surface,

      trailing: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.primary,
          backgroundColor: Colors.transparent,
        ),
        onPressed: () {
          App.gotoPage(
            context,
            MatchFormPage(
              matchNum: match.matchNum.toString(),
              teamNum: match.team.toString(),
              isBlue: match.isBlue,
              driverNumber: match.driveTeamNum,
            ),
          );
        },
        child: const Icon(Icons.add),
      ),

      children: [
        Text(
          match.isBlue ? "Team Color: Blue" : "Team Color: Red",
        ),
        Text(
          "Team Number: ${match.team}",
        ),
        Text(
          "Drive Team Number: ${match.driveTeamNum}",
        ),
        const Padding(padding: EdgeInsets.all(1)),
      ],
    );
  }
}
