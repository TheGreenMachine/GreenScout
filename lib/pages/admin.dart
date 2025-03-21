import 'package:green_scout/pages/admin/edit_users.dart';
import 'package:green_scout/pages/admin/event_change.dart';
import 'package:green_scout/utils/app_state.dart';
import 'package:green_scout/utils/data_for_admins.dart';
import 'package:green_scout/pages/admin/group_admin_assign_matches.dart';
import 'package:green_scout/pages/admin/individual_admin_assign_matches.dart';
import 'package:green_scout/widgets/navigation_layout.dart';
import 'package:green_scout/utils/action_bar.dart';
import 'package:green_scout/utils/hue_shift.dart';
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

/// The admin hub, known as the "Control Panel" in the app.
/// 
/// Contains a list of buttons that redirect to pages related
/// to admin stuff... 
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
    Color buttonColour = Theme.of(context).colorScheme.inversePrimary;
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
              color: valueShift(hueShift(buttonColour, -5), -0.15),
              onPressed: () {
                App.gotoPage(context, const EventConfigPage(), canGoBack: true);
              },
            ),
          ),
          const Padding(padding: EdgeInsets.all(4)),
          const SubheaderLabel("Assign Matches Individually"),
          const Padding(padding: EdgeInsets.all(2)),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85)),
            child: FloatingButton(
              icon: const Icon(Icons.assignment_ind),
              color: valueShift(hueShift(buttonColour, -5), -0.15),
              onPressed: () {
                App.gotoPage(context, const IndividualAdminAssignMatchesPage(),
                    canGoBack: true);
              },
            ),
          ),
          const Padding(padding: EdgeInsets.all(4)),
          const SubheaderLabel("Assign Matches To Group"),
          const Padding(padding: EdgeInsets.all(2)),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85)),
            child: FloatingButton(
              icon: const Icon(Icons.assignment),
              color: valueShift(hueShift(buttonColour, -5), -0.15),
              onPressed: () {
                App.gotoPage(context, const GroupAdminAssignMatchesPage(),
                    canGoBack: true);
              },
            ),
          ),
          const Padding(padding: EdgeInsets.all(4)),
          const SubheaderLabel("Edit information of users"),
          const Padding(padding: EdgeInsets.all(2)),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85)),
            child: FloatingButton(
              icon: const Icon(Icons.supervised_user_circle),
              color: valueShift(hueShift(buttonColour, -5), -0.15),
              onPressed: () {
                App.gotoPage(context, const EditUsersAdminPage(),
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
