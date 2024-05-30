import 'package:green_scout/pages/event_change.dart';
import 'package:green_scout/utils/app_state.dart';
import 'package:green_scout/utils/data_for_admins.dart';
import 'package:green_scout/pages/group_admin_assign_matches.dart';
import 'package:green_scout/pages/individual_admin_assign_matches.dart';
import 'package:green_scout/widgets/navigation_layout.dart';
import 'package:green_scout/utils/action_bar.dart';
import 'package:green_scout/widgets/floating_button.dart';
import 'package:green_scout/widgets/header.dart';
import 'package:green_scout/widgets/subheader.dart';
import 'package:flutter/material.dart';

class MatchDisplayAdminData {
  const MatchDisplayAdminData(
    this.match,
    this.team,
    this.isBlue,
    this.driverStation,
  );

  final int match;
  final int team;

  final bool isBlue;
  final int driverStation;
}

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPage();
}

class _AdminPage extends State<AdminPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdminData.updateUserRoster();
    });
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
          const HeaderLabel("Welcome to the Admin Page!"),
          const Padding(padding: EdgeInsets.all(24)),
          const SubheaderLabel("Change Event"),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85)),
            child: FloatingButton(
              icon: const Icon(Icons.event),
              color: Theme.of(context).colorScheme.inversePrimary.withBlue(255),
              onPressed: () {
                App.gotoPage(context, const EventConfigPage(), canGoBack: true);
              },
            ),
          ),
          const Padding(padding: EdgeInsets.all(2)),
          const SubheaderLabel("Assign Matches Individually"),
          const Padding(padding: EdgeInsets.all(2)),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85)),
            child: FloatingButton(
              icon: const Icon(Icons.assignment_ind),
              color: Theme.of(context).colorScheme.inversePrimary.withBlue(255),
              onPressed: () {
                App.gotoPage(context, const IndividualAdminAssignMatchesPage(),
                    canGoBack: true);
              },
            ),
          ),
          const Padding(padding: EdgeInsets.all(16)),
          const SubheaderLabel("Assign Matches To Group"),
          const Padding(padding: EdgeInsets.all(2)),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85)),
            child: FloatingButton(
              icon: const Icon(Icons.assignment),
              color: Theme.of(context).colorScheme.inversePrimary.withBlue(255),
              onPressed: () {
                App.gotoPage(context, const GroupAdminAssignMatchesPage(),
                    canGoBack: true);
              },
            ),
          ),
          const Padding(padding: EdgeInsets.all(40)),
        ],
      ),
    );
  }
}
