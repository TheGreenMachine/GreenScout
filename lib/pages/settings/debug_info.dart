import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:dart_ipify/dart_ipify.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:green_scout/utils/app_state.dart';
import 'package:green_scout/utils/general_utils.dart';
import 'package:green_scout/utils/main_app_data_helper.dart';
import 'package:green_scout/utils/action_bar.dart';
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

  StreamController<String> eventKeyController = StreamController();
  Stream<String> eventKey = const Stream.empty();

  @override
  void initState() {
    super.initState();

    userIpAddress = userIpAddressController.stream;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      userIpAddressController.add(await Ipify.ipv4());
    });

    eventKey = eventKeyController.stream;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!(App.getBool("Debugger") ?? false)) {
        MainAppData.triggerDebug(context);
      }

      await App.httpRequest("generalInfo", "", onGet: (response) {
        Map<dynamic, dynamic> json = jsonDecode(response.body);
        String? nameFromJson = json["EventName"];
        String? keyFromJson = json["EventKey"];

        if (nameFromJson != null && keyFromJson != null) {
          eventKeyController.add("Key: $keyFromJson     Name: $nameFromJson");
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final (width, widthPadding) =
        screenScaler(MediaQuery.of(context).size.width, 670, 0.5, 1.0);

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
              stream: userIpAddress,
              builder: (context, value) {
                return buildInfoTile(context, widthPadding, width, Icons.wifi,
                    "IP Address", value.data ?? "NO IP ADDRESS FOUND");
              },
            ),
            StreamBuilder(
              stream: eventKey,
              builder: (context, value) {
                return buildInfoTile(
                    context,
                    widthPadding,
                    width,
                    Icons.event,
                    "Event Data",
                    value.data ?? "Unable to retrieve from server");
              },
            ),
            buildInfoTile(context, widthPadding, width, Icons.perm_identity,
                "UUID", MainAppData.userUUID),
            buildInfoTile(context, widthPadding, width, Icons.data_object,
                "Certificate", MainAppData.userCertificate),
            buildActionTile(
                context,
                widthPadding,
                width,
                Icons.restore,
                "Reset Lifetime Matches",
                "Gets rid of all the cached matches stored", () {
              App.promptAlert(
                context,
                "Clear All Cached Matches?",
                "This action is irreversible. Make sure that you know what you are doing.",
                [
                  (
                    "Yes",
                    () {
                      Navigator.of(context).pop();
                      MainAppData.resetAllTimeMatchCache();
                      setState(() {});
                      App.showMessage(context, "Cleared Lifetime Match Cache");
                    }
                  ),
                  ("No", null),
                ],
              );
            }),
            buildActionTile(
                context,
                widthPadding,
                width,
                Icons.restore_from_trash,
                "Reset Temporary Matches",
                "Gets rid of all the temporary cached matches stored", () {
              App.promptAlert(
                context,
                "Clear All Cached Temporary Matches?",
                "This action is irreversible. Make sure that you know what you are doing.",
                [
                  (
                    "Yes",
                    () {
                      Navigator.of(context).pop();
                      MainAppData.resetImmediateMatchCache();
                      App.showMessage(context, "Cleared Temporary Match Cache");
                    }
                  ),
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
                  itemBuilder: (context, index) =>
                      buildMatchCacheTile(context, index, matches),
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

  Widget buildMatchCacheTile(
      BuildContext context, int index, List<String> matches) {
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
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
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

                if (context.mounted) {
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
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
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

                if (context.mounted) {
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

  Widget buildActionTile(
      BuildContext context,
      double widthPadding,
      double width,
      IconData icon,
      String label,
      String content,
      void Function() callback) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: widthPadding),
        child: SizedBox(
          width: width,
          child: ListTile(
            leading: Icon(icon),
            title: Text(label, style: Theme.of(context).textTheme.labelLarge),
            subtitle:
                Text(content, style: Theme.of(context).textTheme.labelSmall),
            hoverColor: Theme.of(context).colorScheme.inversePrimary,
            onTap: callback,
          ),
        ));
  }

  Widget buildInfoTile(BuildContext context, double widthPadding, double width,
      IconData icon, String label, String content) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widthPadding),
      child: SizedBox(
          width: width,
          child: ListTile(
            leading: Icon(icon),
            title: Text(label, style: Theme.of(context).textTheme.labelLarge),
            subtitle:
                Text(content, style: Theme.of(context).textTheme.labelSmall),
            onLongPress: () async {
              await Clipboard.setData(ClipboardData(text: content));

              if (context.mounted) {
                App.showMessage(
                    context, "Copied '$label' To Clipboard Successfully!");
              }
            },
            hoverColor: Theme.of(context).colorScheme.inversePrimary,
          )),
    );
  }
}
