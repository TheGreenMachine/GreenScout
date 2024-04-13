import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:green_scout/globals.dart';
import 'package:green_scout/pages/navigation_layout.dart';
import 'package:green_scout/pages/settings/debug_info.dart';
import 'package:green_scout/pages/settings/match_form_layout.dart';
import 'package:green_scout/widgets/action_bar.dart';
import 'package:green_scout/widgets/header.dart';

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
    double widthRatio = 1.0;

    const ratioThresold = 670;

    {
      final width = MediaQuery.of(context).size.width;

      final percent = clampDouble(((width - ratioThresold) / (ratioThresold)), 0.0, 1.0);

      widthRatio = (1.0 - 0.50 * percent);
    }

    final width = MediaQuery.of(context).size.width * widthRatio;
    final widthPadding = MediaQuery.of(context).size.width * (1.0 - widthRatio) / 2;



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

          buildSettingTile(context, widthPadding, Icons.format_list_bulleted_outlined, "Match Form Layout", const SettingsMatchFormLayoutPage()),
          buildSettingTile(context, widthPadding, Icons.developer_board, "Debug Info", const SettingsDebugInfoPage()),
        ],
      ),
    );
  }

  Widget buildSettingTile(BuildContext context, double widthPadding, IconData icon, String label, Widget page) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widthPadding),

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
      )
    );
  }
}