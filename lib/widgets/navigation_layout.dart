import 'dart:convert';

import 'package:green_scout/main.dart';
import 'package:green_scout/pages/achievements.dart';
import 'package:green_scout/pages/extras.dart';
import 'package:green_scout/pages/hall_of_fame.dart';
import 'package:green_scout/utils/app_state.dart';
import 'package:green_scout/pages/admin.dart';
import 'package:green_scout/pages/home.dart';
import 'package:green_scout/pages/leaderboard.dart';
import 'package:green_scout/pages/login_as_user.dart';
import 'package:flutter/material.dart';
import 'package:green_scout/pages/match_form.dart';
import 'package:green_scout/pages/settings.dart';
import 'package:green_scout/utils/general_utils.dart';
import 'package:green_scout/utils/main_app_data_helper.dart';
import 'package:green_scout/widgets/subheader.dart';

// The main area to place all relevent navigation.
class NavigationLayoutDrawer extends StatelessWidget {
  const NavigationLayoutDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    final (width, _) = screenScalerBounded(
      MediaQuery.of(context).size.width,
      755,
      455,
      0.75,
      0.55,
    );

    return Drawer(
      width: width,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
      child: Column(
        children: [
          const Padding(padding: EdgeInsets.all(6)),
          ListTile(
            // subtitle: Text("TODO User / Admin / Super"),
            visualDensity: VisualDensity.comfortable,

            dense: false,

            subtitle: Container(
              color: Colors.transparent,
              child: LayoutBuilder(builder: (context, constraint) {
                return SizedBox(
                  width: constraint.biggest.width,
                  child: Text(
                    MainAppData.isAdmin ? "Admin" : "User",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              }),
            ),

            leading: Container(
              color: Colors.transparent,
              child: LayoutBuilder(builder: (context, constraint) {
                return App.getPfp();
              }),
            ),

            title: Text(
              MainAppData.displayName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SizedBox(
            width: width,
            height: height * 0.65,
            child: ListView(
              children: [
                const Padding(padding: EdgeInsets.all(8)),
                const SubheaderLabel("Pages"),
                buildNavigationButton(
                    context, Icons.home, "Home", const HomePage()),
                buildNavigationButton(
                    context, Icons.create, "Match Form", const MatchFormPage()),
                buildNavigationButton(context, Icons.leaderboard,
                    "Leaderboards", const LeaderboardPage()),
                buildNavigationButton(context, Icons.emoji_events_sharp,
                    "Hall of Fame", const HallOfFamePage()),
                buildNavigationButton(context, Icons.star, "Achievements",
                    const AchievementsPage()),
                if (manager.achievements["Strategizer"]!.met ||
                    manager.achievements["Foreign Fracas"]!.met)
                  buildNavigationButton(context, Icons.emoji_emotions_rounded,
                      "Extras", const ExtrasPage()),
                ...buildAdminPanelNavigation(context),
              ],
            ),
          ),
          Expanded(child: Container()),
          buildNavigationButton(
              context, Icons.settings, "Settings", const SettingsPage()),
          ListTile(
            // subtitle: Text("TODO User / Admin / Super"),
            visualDensity: VisualDensity.comfortable,

            hoverColor: Theme.of(context).colorScheme.inversePrimary,

            dense: false,

            leading: Container(
              color: Colors.transparent,
              child: LayoutBuilder(builder: (context, constraint) {
                return Icon(Icons.logout, size: constraint.biggest.height / 3);
              }),
            ),

            onTap: () {
              App.promptAlert(
                context,
                "Logging Out?",
                null,
                [
                  (
                    "Yes",
                    () {
                      MainAppData.loggedIn = false;
                      App.gotoPage(context, const LoginPageForUsers());
                    }
                  ),
                  ("No", null),
                ],
              );
            },

            title: Text(
              "Log out",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildAdminPanelNavigation(BuildContext context) {
    if (!MainAppData.isAdmin) {
      return [];
    }

    return [
      const Padding(padding: EdgeInsets.all(16)),
      const SubheaderLabel("Admin"),
      buildNavigationButton(context, Icons.admin_panel_settings,
          "Control Panel", const AdminPage()),
    ];
  }

  Widget buildNavigationButton(
      BuildContext context, IconData icon, String label, Widget page) {
    return ListTile(
      onTap: () {
        App.gotoPage(context, page);
      },
      hoverColor: Theme.of(context).colorScheme.inversePrimary,
      visualDensity: VisualDensity.comfortable,
      dense: true,
      leading: Container(
        color: Colors.transparent,
        child: LayoutBuilder(builder: (context, constraint) {
          return Icon(icon, size: constraint.biggest.height / 2);
        }),
      ),
      title: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}
