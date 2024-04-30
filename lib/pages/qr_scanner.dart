import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:green_scout/utils/app_state.dart';
import 'package:green_scout/pages/preference_helpers.dart';
import 'package:green_scout/pages/qr_main_hub.dart';
import 'package:green_scout/widgets/action_bar.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPage();
}

class _QRScannerPage extends State<QRScannerPage> {
  StreamController<bool> controller = StreamController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    });
  }

  @override
  void dispose() {
    controller.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        actions: createEmptyActionBar(),
      ),

      body: StreamBuilder( 
        stream: controller.stream,

        builder: (context, snapshot) {
          return MobileScanner(
            onDetect: (capture) { 
              final barcodes = capture.barcodes;

              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  log("We've gotten ${barcode.rawValue!}");
                  addToMatchCache(barcode.rawValue!);

                  App.gotoPage(context, const QRCodeMainHubPage());
                  App.showMessage(context, "Successfully Scanned QR Code!");
                }
              }
            },
              
          );
        },
      ),
    );
  }
}