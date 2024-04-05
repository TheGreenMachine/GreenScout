import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:green_scout/globals.dart';
import 'package:green_scout/pages/preference_helpers.dart';
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

    final matches = getAllTimeMatchCache();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        actions: createEmptyActionBar(),
      ),

      body: Column(
        children: [
          StreamBuilder(
            stream: userIpAddress, builder: (context, value) {
              return buildInfoTile(context, widthPadding, Icons.wifi, "IP Address", value.data ?? "NO IP ADDRESS FOUND");
            },
          ),
          buildInfoTile(context, widthPadding, Icons.perm_identity, "UUID", getUserUUID()),
          buildInfoTile(context, widthPadding, Icons.data_object, "Certificate", getCertificate()),

          const Padding(padding: EdgeInsets.all(8)),
          const SubheaderLabel("Cached Matches"),

          SizedBox(
            width: width,
            // height: MediaQuery.of(context).size.height * 0.85,
            // height: double.infinity,

            child: ListView.builder(
              itemBuilder: (context, index) => buildMatchCacheTile(context, index, matches),

              itemCount: matches.length,
              
              shrinkWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMatchCacheTile(BuildContext context, int index, List<String> matches) {
    final matchJson = matches[index];

    try {
      final jsonData = jsonDecode(matchJson);

      return ExpansionTile(
        title: Text("${jsonData["Match"]["Number"]} Replay: ${jsonData["Match"]["Replay"]}"),
      );

    } catch (e) {
      return const Padding(padding: EdgeInsets.zero);
    }
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