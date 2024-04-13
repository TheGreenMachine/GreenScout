import 'package:flutter/foundation.dart';
import 'package:green_scout/globals.dart';
import 'package:green_scout/pages/admin.dart';
import 'package:green_scout/pages/home.dart';
import 'package:green_scout/pages/leaderboard.dart';
import 'package:green_scout/pages/login_as_user.dart';
import 'package:flutter/material.dart';
import 'package:green_scout/pages/match_form.dart';
import 'package:green_scout/pages/match_form_2.dart';
import 'package:green_scout/pages/settings.dart';
import 'package:green_scout/widgets/subheader.dart';
import 'login_as_guest.dart';
import 'preference_helpers.dart';

// The main area to place all relevent navigation.
class NavigationLayoutDrawer extends StatelessWidget {
  const NavigationLayoutDrawer({super.key});
  
  @override 
  Widget build(BuildContext context) {
    double widthRatio = 0.75;

    const lowerLimit = 455;
    const upperLimit = 755;

    {
      final width = MediaQuery.of(context).size.width;

      final percent = clampDouble(((width - lowerLimit) / (upperLimit - lowerLimit)), 0.0, 1.0);

      widthRatio = (0.75 - 0.20 * percent);
    }

    final width = MediaQuery.of(context).size.width * widthRatio;
    final height = MediaQuery.of(context).size.height;

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
                    isAdmin() ? "Admin" : "User",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              }),
            ),

            leading: Container(
              color: Colors.transparent,
              child: LayoutBuilder(builder: (context, constraint) {
                return Icon(Icons.account_circle, size: constraint.biggest.height);
              }),
            ),

            title: Text(
              getScouterName(),
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

                buildNavigationButton(context, Icons.home, "Home", const HomePage()),
                buildNavigationButton(context, Icons.create, "Match Form", Settings.useOldLayout.value ? const MatchFormPage() : const MatchFormPage2()),
                buildNavigationButton(context, Icons.leaderboard, "Leaderboards", const LeaderboardPage()),

                ...buildAdminPanelNavigation(context),
              ],
            ),
          ),

          Expanded(child: Container()),

          buildNavigationButton(context, Icons.settings, "Settings", const SettingsPage()),

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
                  ("Yes", () { setLoginStatus(false); App.gotoPage(context, const LoginPageForUsers()); }),
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
    if (!isAdmin()) {
      return [];
    }

    return [
      const Padding(padding: EdgeInsets.all(16)),

      const SubheaderLabel("Admin"),
      buildNavigationButton(context, Icons.admin_panel_settings, "Control Panel", const AdminPage()),
    ];
  }

  Widget buildNavigationButton(BuildContext context, IconData icon, String label, Widget page) {
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