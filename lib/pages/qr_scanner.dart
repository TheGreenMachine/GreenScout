import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPage();
}

class _QRScannerPage extends State<QRScannerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MobileScanner(onDetect: (capture) { 
        log("Got something! $capture"); 
        final barcodes = capture.barcodes;

        for (final barcode in barcodes) {
          if (barcode.displayValue != null) {
            log("We got ${barcode.displayValue!}");
          }

          log(barcode.toString());
          
          if (barcode.rawValue != null) {
            log("We've gotten ${barcode.rawValue!}");
          }
        }
      })
    );
  }
}