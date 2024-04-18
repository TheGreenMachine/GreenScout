import 'package:flutter/material.dart';
import 'package:green_scout/widgets/action_bar.dart';
import 'package:green_scout/widgets/subheader.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DisplayQRCodePage extends StatefulWidget {
  const DisplayQRCodePage({
    super.key,
    required this.jsonContent,
    required this.team,
    required this.match,
    required this.isBlue,
    required this.driverNumber,
  });

  final int team;
  final int match;
  final bool isBlue;
  final int driverNumber;
  final String jsonContent;

  @override
  State<DisplayQRCodePage> createState() => _DisplayQRCodePage();
}

class _DisplayQRCodePage extends State<DisplayQRCodePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        actions: createEmptyActionBar(),
      ),

      body: ListView(
        children: [
          SubheaderLabel("Match ${widget.match}, Team ${widget.team}\nDriver Number ${widget.driverNumber} Blue: ${widget.isBlue}"),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,

            child: QrImageView(data: widget.jsonContent, size: MediaQuery.of(context).size.width,),
          ),
        ],
      ),
    );
  }
}