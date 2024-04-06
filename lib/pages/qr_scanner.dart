import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:green_scout/globals.dart';
import 'package:green_scout/pages/match_form.dart';
import 'package:green_scout/pages/navigation_layout.dart';
import 'package:green_scout/widgets/action_bar.dart';

class QRCodeScannerPage extends StatefulWidget {
  const QRCodeScannerPage({super.key});

  @override
  State<QRCodeScannerPage> createState() => _QRCodeScannerPage();
}

class _QRCodeScannerPage extends State<QRCodeScannerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: createDefaultActionBar(),
      ),

      drawer: const NavigationLayoutDrawer(),

      body: ListView(
        children: [
          SizedBox(
            width: 400,
            height: 400,

            child: ElevatedButton(
              onPressed: () async {
                final res = Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MatchFormPage()));
                
                log("Got Result: $res");
              },

              child: Text("What?"),
            ),
          ),
        ],
      ),
    );
  }
}