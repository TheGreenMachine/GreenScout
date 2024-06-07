import 'package:flutter/material.dart';
import 'package:green_scout/pages/settings/user_info.dart';
import 'package:green_scout/utils/achievement_manager.dart';
import 'package:green_scout/utils/app_state.dart';
import 'package:green_scout/widgets/navigation_layout.dart';
import 'package:green_scout/pages/settings/debug_info.dart';
import 'package:green_scout/pages/settings/match_form_layout.dart';
import 'package:green_scout/utils/general_utils.dart';
import 'package:green_scout/utils/action_bar.dart';
import 'package:green_scout/widgets/header.dart';

/// A page that hosts buttons that redirect to other pages
/// for things related to customization or debugging. 
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Settings.update();
    });
  }

  @override
  Widget build(BuildContext context) {
    final (width, widthPadding) =
        screenScaler(MediaQuery.of(context).size.width, 670, 0.5, 1.0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: createDefaultActionBar(),
      ),
      drawer: const NavigationLayoutDrawer(),
      body: ListView(
        children: [
          const Padding(padding: EdgeInsets.all(4)),
          const HeaderLabel("Settings"),
          buildSettingTile(
            context,
            widthPadding,
            width,
            Icons.format_list_bulleted_outlined,
            "Match Form Layout",
            const SettingsMatchFormLayoutPage(),
          ),
          buildSettingTile(context, widthPadding, width, Icons.developer_board,
              "Debug Info", const SettingsDebugInfoPage()),
          if (AchievementManager.displayNameUnlocked.value ||
              AchievementManager.profileChangeUnlocked.value)
            buildSettingTile(context, widthPadding, width, Icons.dataset_sharp,
                "Edit User Info", const UserInfoPage()),
        ],
      ),
    );
  }

  Widget buildSettingTile(BuildContext context, double widthPadding,
      double width, IconData icon, String label, Widget page) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widthPadding),
      child: SizedBox(
        width: width,
        child: ListTile(
          leading: Icon(icon),
          hoverColor: Theme.of(context).colorScheme.inversePrimary,
          onTap: () {
            App.gotoPage(context, page, canGoBack: true);
          },
          title: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          titleAlignment: ListTileTitleAlignment.center,
        ),
      ),
    );
  }
}
