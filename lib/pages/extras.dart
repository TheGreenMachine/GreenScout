import 'dart:math';

import 'package:flutter/material.dart';
import 'package:green_scout/pages/extras/gallery.dart';
import 'package:green_scout/utils/achievement_manager.dart';
import 'package:green_scout/utils/app_state.dart';
import 'package:green_scout/utils/main_app_data_helper.dart';
import 'package:green_scout/widgets/navigation_layout.dart';
import 'package:green_scout/utils/general_utils.dart';
import 'package:green_scout/utils/action_bar.dart';
import 'package:green_scout/widgets/header.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ExtrasPage extends StatefulWidget {
  const ExtrasPage({super.key});

  @override
  State<ExtrasPage> createState() => _ExtrasPage();
}

class _ExtrasPage extends State<ExtrasPage> {
  @override
  void initState() {
    super.initState();
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
          const HeaderLabel("Extras"),
          if (MainAppData.isTeamVerified) buildSpreadsheetRedirect(context),
          if (AchievementManager.nazHighlightsUnlocked)
            buildRedirectButton(context, Image.asset("assets/extras/naz.png"),
                "Naz Reid highlights", naz),
          if (AchievementManager.rudyHighlightsUnlocked)
            buildRedirectButton(context, Image.asset("assets/extras/rudy.png"),
                "Rudy Gobert highlights", rudy),
          if (AchievementManager.routerGalleryUnlocked)
            buildNavigationButton(context, Icons.camera_alt,
                "Ryan McGoff Photo Gallery", const PhotoGalleryPage())
        ],
      ),
    );
  }

  var naz = [
    ("https://youtu.be/PSr8E1KUsN8?si=lLtI79PjKsav4d1A"),
    ("https://youtu.be/hrTrAcTpi3Q?si=Z5Jrtg7vp8dBEUup"),
    ("https://youtu.be/xzEDrK6ZNeg?si=n7QUAdrr2WC4qCMd"),
  ];

  var rudy = [
    "https://youtu.be/ZyCO0Kpzy6I?si=OFdN1fQBx7oFtxhf",
    "https://youtu.be/uiMAJcdJwJ8?si=psfnVneeYauLzJpK",
    "https://youtu.be/rvB1SKnyopw?si=o0s3ASg9Pl1Ytdgb",
    "https://youtu.be/wskHuqMTdR4?si=j-D-1sgmqOg0j0Rw"
  ];

  Widget buildSpreadsheetRedirect(BuildContext context) {
    return ListTile(
      onTap: () async {
        await launchUrlString(await MainAppData.getSpreadsheetLink());
        if (!AchievementManager.nazHighlightsUnlocked) {
          MainAppData.triggerStrategizer(context);
        }
      },
      hoverColor: Theme.of(context).colorScheme.inversePrimary,
      visualDensity: VisualDensity.comfortable,
      dense: true,
      leading: Container(
        color: Colors.transparent,
        child: LayoutBuilder(builder: (context, constraint) {
          return const Icon(Icons.grid_on_rounded);
        }),
      ),
      title: Text(
        "Spreadsheet link",
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }

  Widget buildRedirectButton(
      BuildContext context, Widget image, String label, List<String> urls) {
    return ListTile(
      onTap: () async {
        await launchUrlString(urls[Random().nextInt(urls.length)]);
      },
      hoverColor: Theme.of(context).colorScheme.inversePrimary,
      visualDensity: VisualDensity.comfortable,
      dense: true,
      leading: Container(
        color: Colors.transparent,
        child: LayoutBuilder(builder: (context, constraint) {
          return image;
        }),
      ),
      title: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
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
