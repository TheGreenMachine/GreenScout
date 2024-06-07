import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:green_scout/utils/app_state.dart';

/// A widget that's only purpose is to display an icon letting users know
/// if there is problems connecting to the server.
class InternetIndicator extends StatefulWidget {
  const InternetIndicator({super.key});
  
  @override
  State<InternetIndicator> createState() => _InternetIndicator();
}

class _InternetIndicator extends State<InternetIndicator> {
  bool previouslyOnline = App.internetOn;
  late Timer periodicChecker;

  @override
  void initState() {
    periodicChecker = Timer.periodic(
      const Duration(seconds: 1), 
      (timer) {
        if (previouslyOnline != App.internetOn) {
          setState(() => previouslyOnline = App.internetOn);
        }
      },
    );

    super.initState();
  }

  @override
  void dispose() {
    periodicChecker.cancel();

    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (App.internetOff) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Tooltip(
          message: "Unable to connect to the server.",
          preferBelow: true,

          child: Icon(
            Icons.wifi_off, 
            color: Colors.red.shade600, 
            shadows: [Shadow(offset: Offset.fromDirection(pi / 2, 0.35))],
          ),
        ),
      );
    }

    return const Padding(padding: EdgeInsets.zero);
  }
}