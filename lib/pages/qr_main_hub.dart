import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:green_scout/utils/app_state.dart';
import 'package:green_scout/pages/display_qr_code.dart';
import 'package:green_scout/pages/navigation_layout.dart';
import 'package:green_scout/pages/preference_helpers.dart';
import 'package:green_scout/pages/qr_scanner.dart';
import 'package:green_scout/widgets/action_bar.dart';
import 'package:green_scout/widgets/floating_button.dart';
import 'package:green_scout/widgets/header.dart';
import 'package:green_scout/widgets/subheader.dart';

class QRCodeMainHubPage extends StatefulWidget {
  const QRCodeMainHubPage({super.key});

  @override
  State<QRCodeMainHubPage> createState() => _QRCodeMainHubPage();
}

class _QRCodeMainHubPage extends State<QRCodeMainHubPage> {
  @override
  Widget build(BuildContext context) {
    final matches = getAllTimeMatchCache();

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
          const HeaderLabel("QR Hub"),

          Padding( 
            padding: EdgeInsets.symmetric(horizontal: 15),

            child: FloatingButton(
              labelText: "Scan & Store",
              color: Theme.of(context).colorScheme.inversePrimary,
              onPressed: () {
                App.gotoPage(context, const QRScannerPage(), canGoBack: true);
              },
            ),
          ),

          const SubheaderLabel("Saved Matches To QR"),
          buildScrolllableQRCodeGenerators(context, widthPadding, width, matches),
        ],
      ),
    );
  }

  Widget buildScrolllableQRCodeGenerators(BuildContext context, double widthPadding, double width, List<String> matches) {
    final tiles = <Widget>[];

    for (final (index, _) in matches.indexed) {
      tiles.add(buildQRCodeGeneratorTile(context, widthPadding, index, matches));
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.70,
      width: width,

      child: ListView.builder(
        clipBehavior: Clip.antiAlias,

        itemBuilder: (context, index) => buildQRCodeGeneratorTile(context, widthPadding, index, matches),
        itemCount: matches.length,

        shrinkWrap: true,
      ),
    );
  }

  Widget buildQRCodeGeneratorTile(BuildContext context, double widthPadding, int index, List<String> matches) {
    final match = matches[index];

    String title;
    String leading;

    try {
      final jsonContent = jsonDecode(match);

      title = jsonContent["Team"].toString();

      // Terrible code... but it's compact!
      leading = "${jsonContent["Driver Station"]["Number"]}${jsonContent["Driver Station"]["Is Blue"] ? "B" : "R"}";

      if (jsonContent["Mangled"]) {
        return const Padding(padding: EdgeInsets.zero); 
      }
    } catch (e) {
      log("Encountered an exception when building qr code tiles: $e");

      // We return nothing if we encounter something is mangled.
      return const Padding(padding: EdgeInsets.zero);
    }
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widthPadding),

      child: ListTile(
        leading: Text(leading),
        title: Text(title),

        hoverColor: Theme.of(context).colorScheme.inversePrimary,
        splashColor: Theme.of(context).colorScheme.primary,

        onTap: () {
          App.showMessage(context, "Hold Tile To Send As QR");
        },

        onLongPress: () {
          final matchJson = jsonDecode(match);

          // We want to get rid of the notes data.
          // We can already only barely hold onto the content
          // we store.
          matchJson["Notes"] = "";

          App.gotoPage(context, DisplayQRCodePage(
            match: matchJson["Match"]["Number"],
            team: matchJson["Team"],
            isBlue: matchJson["Driver Station"]["Is Blue"],
            driverNumber: matchJson["Driver Station"]["Number"],
            jsonContent: jsonEncode(matchJson),
          ), canGoBack: true);
        },
      ),
    );
  }
}