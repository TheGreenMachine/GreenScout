import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:green_scout/globals.dart';
import 'package:green_scout/pages/navigation_layout.dart';
import 'package:green_scout/reference.dart';
import 'package:green_scout/widgets/action_bar.dart';
import 'package:green_scout/widgets/dropdown.dart';
import 'package:green_scout/widgets/floating_button.dart';
import 'package:green_scout/widgets/header.dart';
import 'package:green_scout/widgets/number_counter.dart';
import 'package:green_scout/widgets/subheader.dart';
import 'package:green_scout/widgets/toggle_floating_button.dart';

class MatchFormPage2 extends StatefulWidget {
  const MatchFormPage2({
    super.key,
  });

  @override
  State<MatchFormPage2> createState() => _MatchFormPage2();
}

class _MatchFormPage2 extends State<MatchFormPage2> {
  Reference<(bool, int)> driverStation = Reference((false, 1));

  Reference<bool> canClimbSuccessfully = Reference(false);

  Reference<bool> canDoAuto = Reference(false);
  Reference<int> autoScores = Reference(0);
  Reference<int> autoMisses = Reference(0);
  Reference<int> autoEjects = Reference(0);

  Reference<bool> canDistanceShoot = Reference(false);
  Reference<int> distanceScores = Reference(0);
  Reference<int> distanceMisses = Reference(0);

  Stopwatch climbingStopwatch = Stopwatch();
  double climbingTime = 0.0;
  bool climbingTimerActive = false;

  Reference<bool> shootingPositionMiddle = Reference(false);
  Reference<bool> shootingPositionSides = Reference(false);

  Reference<bool> pickupGround = Reference(false);
  Reference<bool> pickupSource = Reference(false);

  Reference<int> trapScores = Reference(0);
  Reference<int> trapMisses = Reference(0);

  @override
  Widget build(BuildContext context) {
    if (climbingTimerActive) {
      climbingStopwatch.start();

      Timer.periodic(
        const Duration(milliseconds: 150), 
        (timer) { 
          if (!timer.isActive) {
            return;
          }

          if (!climbingTimerActive) {
            timer.cancel();
            climbingStopwatch.stop();
          }

          setState(() {
            climbingTime = climbingStopwatch.elapsedMilliseconds.toDouble() / 1000;
          });
        },
      );

    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        actions: createDefaultActionBar(),
      ),

      drawer: const NavigationLayoutDrawer(),

      body: Row(
        children: [
          buildMainContent(context),

          const VerticalDivider(width: 0.1, thickness: 0,),

          buildNavigationRail(context),
        ],
      ),
    );
  }

  Widget buildNavigationRail(BuildContext context) {
    var climberTimerIcon = Icon(
      Icons.timer,

      color: climbingTimerActive
      ? Theme.of(context).colorScheme.primary
      : null,
    );

    return NavigationRail(
      destinations: [
        const NavigationRailDestination(icon: Icon(Icons.amp_stories), label: Text("Amp")),
        const NavigationRailDestination(icon: Icon(Icons.speaker), label: Text("Speaker")),
        const NavigationRailDestination(icon: Icon(Icons.airport_shuttle), label: Text("Shuttle")),
        const NavigationRailDestination(icon: Icon(Icons.social_distance), label: Text("Distance")),

        NavigationRailDestination(
          icon: climberTimerIcon,
          label: Text('Climbing'),
          indicatorColor: Color.fromARGB(255, 255, 0, 0),
        ),
      ], 
      selectedIndex: null,
      labelType: NavigationRailLabelType.all,
      
      backgroundColor: Theme.of(context).colorScheme.surface,

      onDestinationSelected: (index) {
        setState(() {
          if (index == 4) {
            climbingTimerActive = !climbingTimerActive;
          }
        });
      },
    );
  }

  Widget buildMainContent(BuildContext context) {
    const widthRatio = 0.98;

    final width = MediaQuery.of(context).size.width * widthRatio;
    final widthPadding = MediaQuery.of(context).size.width * (1.0 - widthRatio) / 2;

    const centeredWidthRatio = 0.85;

    final centeredWidth = MediaQuery.of(context).size.width * centeredWidthRatio;
    final centeredWidthPadding = MediaQuery.of(context).size.width * (1.0 - centeredWidthRatio) / 2;

    const textBoxHeightRatio = 0.1;

    final textBoxHeight = MediaQuery.of(context).size.height * textBoxHeightRatio;

    return Expanded(
      child: ListView(
        children: [
          const Padding(padding: EdgeInsets.all(8)),

          buildTextNumberContainer(context, centeredWidthPadding, 3, "Match #", Reference(""), TextEditingController()),
          const Padding(padding: EdgeInsets.all(5)),
          buildTextNumberContainer(context, centeredWidthPadding, 5, "Team #", Reference(""), TextEditingController()),
          const Padding(padding: EdgeInsets.all(5)),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: centeredWidthPadding),

            child: FloatingToggleButton(
              initialColor: Theme.of(context).colorScheme.inversePrimary.withRed(255),
              pressedColor: Theme.of(context).colorScheme.inversePrimary,

              labelText: "Is Replay?",

              initialIcon: const Icon(Icons.close),
              pressedIcon: const Icon(Icons.check),
            ),
          ),

          createLabelAndDropdown<(bool, int)>(
            "Driver Station",
            {
              "Red 1": (false, 1),
              "Red 2": (false, 2),
              "Red 3": (false, 3),

              "Blue 1": (true, 1),
              "Blue 2": (true, 2),
              "Blue 3": (true, 3),
            }, 
            driverStation, 
            (false, 1),
          ),

          const Padding(padding: EdgeInsets.all(3)),
          const Divider(height: 2,),
          const Padding(padding: EdgeInsets.all(3)),

          ExpansionTile(
            title: Text(
              "Cycles",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),

            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.25,

                child: ListView(
                  children: [
                    // Example data until I set up the system.
                    buildCycleTile(context, 0),
                    buildCycleTile(context, 2),
                    buildCycleTile(context, 1),
                    buildCycleTile(context, 3),
                    buildCycleTile(context, 2),
                    buildCycleTile(context, 0),
                    buildCycleTile(context, 3),
                    buildCycleTile(context, 2),
                    buildCycleTile(context, 2),
                    buildCycleTile(context, 0),
                    buildCycleTile(context, 3),
                    buildCycleTile(context, 3),
                    buildCycleTile(context, 0),
                    buildCycleTile(context, 1),
                    buildCycleTile(context, 2),
                    buildCycleTile(context, 3),
                    buildCycleTile(context, 3),
                    buildCycleTile(context, 3),
                    buildCycleTile(context, 3),
                    buildCycleTile(context, 0),
                    buildCycleTile(context, 2),
                    buildCycleTile(context, 0),
                    buildCycleTile(context, 2),
                    buildCycleTile(context, 1),
                    buildCycleTile(context, 0),
                  ],
                ),
              ),
            ],
          ),

          const Padding(padding: EdgeInsets.all(8)),
          const Divider(height: 2,),
          const Padding(padding: EdgeInsets.all(3)),

          const SubheaderLabel("Climbing"),
          
          Padding(
            padding: EdgeInsets.symmetric(horizontal: centeredWidthPadding),

            child: FloatingActionButton(
              elevation: 0.0,
              focusElevation: 0.0,
              disabledElevation: 0.0,
              hoverElevation: 0.0,
              highlightElevation:  0.0,

              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),

              onPressed: () {
                App.promptAlert(
                  context, 
                  "Reset Climbing Time?", 
                  "Are you Sure?", 
                  [
                    ("Yes", () {
                      setState(() => climbingTime = 0.0);
                      climbingStopwatch.reset();
                      Navigator.of(context).pop();
                      App.showMessage(context, "Reset Climbing Time");
                    }),
                    ("No", null),
                  ],
                );
              },
              child: const Text("Reset Time"),
            ),
          ),

          createLabelAndCheckBox("Are They Successful?", canClimbSuccessfully),

          const Padding(padding: EdgeInsets.all(4)),

          Text(
            "It Takes Them ${climbingTime.toStringAsPrecision(3)} Seconds To Climb",
            style: Theme.of(context).textTheme.labelLarge,
            textAlign: TextAlign.center,
          ),

          const Padding(padding: EdgeInsets.all(6)),
          const Divider(height: 2,),
          const Padding(padding: EdgeInsets.all(3)),

          const SubheaderLabel("Auto Mode"),

          createLabelAndCheckBox("Can Do It?", canDoAuto),
          createLabelAndNumberField("Scores", autoScores),
          createLabelAndNumberField("Misses", autoMisses),
          createLabelAndNumberField("Ejects", autoEjects),

          const Padding(padding: EdgeInsets.all(3)),
          const Divider(height: 2,),
          const Padding(padding: EdgeInsets.all(3)),
          
          const SubheaderLabel("Distance Shooting"),

          createLabelAndCheckBox("Can Do It?", canDistanceShoot),
          createLabelAndNumberField("Scores", distanceScores),
          createLabelAndNumberField("Misses", distanceMisses),

          const Padding(padding: EdgeInsets.all(3)),
          const Divider(height: 2,),
          const Padding(padding: EdgeInsets.all(3)),

          const SubheaderLabel("Trap"),

          createLabelAndNumberField("Scores", trapScores),
          createLabelAndNumberField("Misses", trapMisses),

          const Padding(padding: EdgeInsets.all(3)),
          const Divider(height: 2,),
          const Padding(padding: EdgeInsets.all(3)),

          const SubheaderLabel("Shooting Position (Speaker / Subwoofer)"),

          createLabelAndCheckBox("Middle", shootingPositionMiddle),
          createLabelAndCheckBox("Sides", shootingPositionSides),

          const Padding(padding: EdgeInsets.all(3)),
          const Divider(height: 2,),
          const Padding(padding: EdgeInsets.all(3)),

          const SubheaderLabel("Pickup Locations"),

          createLabelAndCheckBox("Ground", pickupGround),
          createLabelAndCheckBox("Source", pickupSource),


          const Padding(padding: EdgeInsets.all(16)),
        ],
      ),
    );
  }
  
  Widget buildCycleTile(BuildContext context, int index) {
    return ListTile(
      title: Text("1.45 seconds"),
      subtitle: switch (index) {
        0 => Text("AMP"),
        1 => Text("SPEAKER"),
        2 => Text("SHUTTLE"),
        3 => Text("DISTANCE"),
        _ => Text("ERROR"),
      },

      leading: switch (index) {
        0 => Icon(Icons.amp_stories),
        1 => Icon(Icons.speaker),
        2 => Icon(Icons.airport_shuttle),
        3 => Icon(Icons.social_distance),
        _ => Icon(Icons.error),
      },

      onLongPress: () {
        App.showMessage(context, "TODO: Removed Tile");
      },

      trailing: FloatingActionButton(
        heroTag: null,

        backgroundColor: false 
        ? Theme.of(context).colorScheme.inversePrimary
        : Theme.of(context).colorScheme.inversePrimary.withRed(255),

        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        disabledElevation: 0,
        highlightElevation: 0,

        onPressed: () =>
        setState(() {
          // info.success = !info.success;
        }),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

        child: false
        ? const Icon(Icons.check)
        : const Icon(Icons.close),
      ),

      hoverColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  Widget buildTextNumberContainer(BuildContext context, double widthPadding, int digitLimit, String label, Reference<String> assigned, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widthPadding),

      child: SizedBox(
        // width: centeredWidth,
        height: 48,

        child: TextField(
          controller: null,
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
          // onChanged: (value) => matchNum = value,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(digitLimit),
          ],
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: label,
            floatingLabelAlignment: FloatingLabelAlignment.center,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            labelStyle: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ), 
    );
  }

  Widget createLabelAndDropdown<V>(
    String label,
    Map<String, V> entries,
    Reference<V> inValue,
    V defaultValue,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85) / 2,
        vertical: 5,
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          Dropdown<V>(
            entries: entries,
            inValue: inValue,
            defaultValue: defaultValue,
            textStyle: Theme.of(context).textTheme.labelMedium,
            padding: const EdgeInsets.only(left: 5),
          ),
        ],
      ),
    );
  }

  Widget createLabelAndCheckBox(String question, Reference<bool> condition) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85) / 2,
          vertical: 5),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            child: Text(
              question,
              style: Theme.of(context).textTheme.labelLarge,
              overflow: TextOverflow.ellipsis,
              maxLines: 4,
            ),
          ),
          Checkbox(
            value: condition.value,
            onChanged: (_) => setState(() {
              condition.value = !condition.value;
            }),
          ),
        ],
      ),
    );
  }

  Widget createLabelAndNumberField(String label, Reference<int> number,
      {List<Reference<int>> incrementChildren = const [],
      List<Reference<int>> decrementChildren = const [],
      int lowerBound = 0,
      int upperBound = 99}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85) / 2,
        vertical: 5,
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge,
              overflow: TextOverflow.ellipsis,
              maxLines: 4,
            ),
          ),
          
          NumberCounterButton(
            number: number,

            lowerBound: lowerBound,
            upperBound: upperBound,

            incrementChildren: incrementChildren,
            decrementChildren: decrementChildren,
          ),
        ],
      ),
    );
  }
}