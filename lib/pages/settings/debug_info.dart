import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:green_scout/utils/app_state.dart';
import 'package:green_scout/utils/main_app_data_helper.dart';
import 'package:green_scout/widgets/action_bar.dart';
import 'package:green_scout/widgets/subheader.dart';

import 'package:http/http.dart' as http;

class SettingsDebugInfoPage extends StatefulWidget {
  const SettingsDebugInfoPage({super.key});

  @override
  State<SettingsDebugInfoPage> createState() => _SettingsDeveloperInfoPage();
}

class _SettingsDeveloperInfoPage extends State<SettingsDebugInfoPage> {
  StreamController<String> userIpAddressController = StreamController();
  Stream<String> userIpAddress = const Stream.empty();

  @override
  void initState() {
    super.initState();

    userIpAddress = userIpAddressController.stream;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      const url = 'https://api.ipify.org';

      try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          log(response.body);
          userIpAddressController.add(response.body);
        }
      } catch (e) {
        log("Encountered Exception While Obtaing IP Address: $e");
      }
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

    final matches = MainAppData.allTimeMatchCache;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        actions: createEmptyActionBar(),
      ),

      body: SizedBox(
        width: MediaQuery.of(context).size.width,

        child: ListView(
          children: [
            StreamBuilder(
              stream: userIpAddress, builder: (context, value) {
                return buildInfoTile(context, widthPadding, Icons.wifi, "IP Address", value.data ?? "NO IP ADDRESS FOUND");
              },
            ),
            buildInfoTile(context, widthPadding, Icons.perm_identity, "UUID", MainAppData.userUUID),
            buildInfoTile(context, widthPadding, Icons.data_object, "Certificate", MainAppData.userCertificate),
            buildActionTile(context, widthPadding, Icons.restore, "Reset Lifetime Matches", "Gets rid of all the cached matches stored", () {
              App.promptAlert(
                context, 
                "Clear All Cached Matches?", 
                "This action is irreversible. Make sure that you know what you are doing.", 
                [
                  ("Yes", () {
                    Navigator.of(context).pop();
                    MainAppData.resetAllTimeMatchCache();
                    setState(() {});
                    App.showMessage(context, "Cleared Lifetime Match Cache");
                  }),
                  ("No", null),
                ],
              );
            }),
            
            buildActionTile(context, widthPadding, Icons.restore_from_trash, "Reset Temporary Matches", "Gets rid of all the temporary cached matches stored", () {
              App.promptAlert(
                context, 
                "Clear All Cached Temporary Matches?", 
                "This action is irreversible. Make sure that you know what you are doing.", 
                [
                  ("Yes", () {
                    Navigator.of(context).pop();
                    MainAppData.resetImmediateMatchCache();
                    App.showMessage(context, "Cleared Temporary Match Cache");
                  }),
                  ("No", null),
                ],
              );
            }),

            const Padding(padding: EdgeInsets.all(8)),
            const SubheaderLabel("Cached Matches"),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: widthPadding),

              child: SizedBox(
                width: width,
                height: MediaQuery.of(context).size.height * 0.45,
                // height: double.infinity,

                child: ListView.builder(
                  itemBuilder: (context, index) => buildMatchCacheTile(context, index, matches),

                  itemCount: matches.length,
                  
                  shrinkWrap: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMatchCacheTile(BuildContext context, int index, List<String> matches) {
    final matchJson = matches[index];

    try {
      final jsonData = jsonDecode(matchJson);

      if (jsonData["Mangled"] == true) {
        throw Exception("Force to catch. Might be bad.");
      }

      return ExpansionTile(
        leading: Text(
          "${jsonData["Match"]["Number"]}${jsonData["Driver Station"]["Is Blue"] ? "B" : "R"}",
        ),
        title: Text("Driver Station ${jsonData["Driver Station"]["Number"]}"),

        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,

            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),

            primary: true,
            
            child: Text(
              matchJson,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),

          const Padding(padding: EdgeInsets.all(12)),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),

            child: ElevatedButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: matchJson));

                if (mounted) {
                  App.showMessage(context, "Copied To Clipboard Successfully!");
                }
              }, 

              child: const Text("Add To Clipboard"),
            ),
          ),

          const Padding(padding: EdgeInsets.all(12)),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),

            child: ElevatedButton(
              onPressed: () {
                MainAppData.addToMatchCache(matchJson);

                App.showMessage(context, "Added To Match Sending Queue");
              }, 

              child: const Text("Force Send To Server"),
            ),
          ),

          const Padding(padding: EdgeInsets.all(6)),
        ],
      );

    } catch (e) {
      return ExpansionTile(
        leading: const Text("?"),

        title: const Text("Mangled Match Info"),

        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,

            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),

            primary: true,
            
            child: Text(
              matchJson,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),

          const Padding(padding: EdgeInsets.all(12)),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),

            child: ElevatedButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: matchJson));

                if (mounted) {
                  App.showMessage(context, "Copied To Clipboard Successfully!");
                }
              }, 

              child: const Text("Add To Clipboard"),
            ),
          ),
        ],
      );
    }
  }

  Widget buildActionTile(BuildContext context, double widthPadding, IconData icon, String label, String content, void Function() callback) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widthPadding),

      child: ListTile(
        leading: Icon(icon),
        title: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge
        ),

        subtitle: Text(
          content,
          style: Theme.of(context).textTheme.labelSmall
        ),

        hoverColor: Theme.of(context).colorScheme.inversePrimary,

        onTap: callback,
      )
    );
  }

  Widget buildInfoTile(BuildContext context, double widthPadding, IconData icon, String label, String content) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widthPadding),

      child: ListTile(
        leading: Icon(icon),
        title: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge
        ),

        subtitle: Text(
          content,
          style: Theme.of(context).textTheme.labelSmall
        ),
      )
    );
  }
}