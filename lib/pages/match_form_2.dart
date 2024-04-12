import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:green_scout/globals.dart';
import 'package:green_scout/pages/home.dart';
import 'package:green_scout/pages/navigation_layout.dart';
import 'package:green_scout/pages/preference_helpers.dart';
import 'package:green_scout/reference.dart';
import 'package:green_scout/widgets/action_bar.dart';
import 'package:green_scout/widgets/dropdown.dart';
import 'package:green_scout/widgets/floating_button.dart';
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

enum CycleTimeLocation2 {
  amp,
  speaker,
  shuttle,
  distance,

  none;

  @override
  String toString() {
    return switch(this) {
      amp => "Amp",
      speaker => "Speaker",
      shuttle => "Shuttle",
      distance => "Distance",

      none => "None",

      // This is left just in case we need to add something new...
      // ignore: unreachable_switch_case
      _ => "Unknown",
    };
  }
}

class CycleTimeInfo2 {
  CycleTimeInfo2({
    this.time = 0.0,
    this.success = false,
    this.location = CycleTimeLocation2.none,
  });

  double time;
  bool success;
  CycleTimeLocation2 location;
}

class _MatchFormPage2 extends State<MatchFormPage2> {
  Reference<(bool, int)> driverStation = Reference((false, 1));

  Reference<bool> canClimbSuccessfully = Reference(false);

  Reference<bool> canDoAuto = Reference(false);
  Reference<int> autoScores = Reference(0);
  Reference<int> autoMisses = Reference(0);
  Reference<int> autoEjects = Reference(0);

  Stopwatch climbingStopwatch = Stopwatch();
  double climbingTime = 0.0;
  bool climbingTimerActive = false;

  Stopwatch cycleStopwatch = Stopwatch();
  bool cycleTimerActive = false;
  List<CycleTimeInfo2> cycles = [];

  Reference<bool> shootingPositionMiddle = Reference(false);
  Reference<bool> shootingPositionSides = Reference(false);

  Reference<bool> pickupGround = Reference(false);
  Reference<bool> pickupSource = Reference(false);

  Reference<int> trapScores = Reference(0);
  Reference<int> trapMisses = Reference(0);

  Reference<bool> endgamePark = Reference(false);
  Reference<bool> scouterLostTrack = Reference(false);
  Reference<bool> disconnectOrDisabled = Reference(false);

  TextEditingController matchNumberController = TextEditingController();
  TextEditingController teamNumberController = TextEditingController();
  TextEditingController notesController = TextEditingController();

  bool isReplay = false;
  Reference<String> matchNum = Reference("");
  Reference<String> teamNum = Reference("");
  String notes = "";

  @override
  Widget build(BuildContext context) {
    if (climbingTimerActive) {
      startClimbingStopwatch();
    }

    if (cycleTimerActive) {
      startCycleStopwatch();
    } else {
      endCycleStopwatch();
    }

    matchNumberController.text = matchNum.value;
    teamNumberController.text = teamNum.value;
    notesController.text = notes;

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

  void startClimbingStopwatch() {
    if (climbingStopwatch.isRunning) {
      return;
    }

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

  void startCycleStopwatch() {
    if (cycleStopwatch.isRunning) {
      return;
    }

    cycleStopwatch.start();
  }

  void endCycleStopwatch() {
    if (!cycleStopwatch.isRunning) {
      return;
    }

    cycleStopwatch.stop();
  }

  Widget buildNavigationRail(BuildContext context) {
    var climberTimerIcon = Icon(
      Icons.timer,

      color: climbingTimerActive
      ? Theme.of(context).colorScheme.primary
      : null,
    );

    var cycleTimerIcon = Icon(
      cycleTimerActive ? Icons.stop : Icons.play_arrow,

      color: cycleTimerActive
      ? Colors.red.shade800
      : null,
    );

    return NavigationRail(
      destinations: [
        NavigationRailDestination(
          icon: cycleTimerIcon, 

          // Might want to make text flip flop between "Start" and "Stop".
          label: const Text("Cycles"),
        ),

        NavigationRailDestination(
          icon: Icon(Icons.amp_stories, color: cycleTimerActive ? Colors.blue.shade600 : null,),
          disabled: !cycleTimerActive, 
          label: const Text("Amp"),
        ),

        NavigationRailDestination(
          icon: Icon(Icons.speaker, color: cycleTimerActive ? Colors.blue.shade600 : null,),
          disabled: !cycleTimerActive, 
          label: const Text("Speaker"),
        ),

        NavigationRailDestination(
          icon: Icon(Icons.airport_shuttle, color: cycleTimerActive ? Colors.blue.shade600 : null,),
          disabled: !cycleTimerActive, 
          label: const Text("Shuttle"),
        ),

        NavigationRailDestination(
          icon: Icon(Icons.social_distance, color: cycleTimerActive ? Colors.blue.shade600 : null,),
          disabled: !cycleTimerActive, 
          label: const Text("Distance"),
        ),

        NavigationRailDestination(
          icon: climberTimerIcon,
          label: const Text('Climbing'),
        ),
      ], 
      selectedIndex: null,
      labelType: NavigationRailLabelType.all,
      
      backgroundColor: Theme.of(context).colorScheme.surface,

      onDestinationSelected: (index) {
        setState(() {
          switch (index) {
            // Cycle timer index. Make sure to update when moving around stuff!
            case 0:
              cycleTimerActive = !cycleTimerActive;
              break;
            
            // Cycle buttons for type of shot. Make sure to update when moving around stuff!
            case 1:
            case 2:
            case 3:
            case 4:
              cycles.add(
                CycleTimeInfo2(
                  time: cycleStopwatch.elapsedMilliseconds.toDouble() / 1000,
                  success: true,

                  // Make sure to update this when modifying the previous cases above.
                  location: switch (index) {
                    1 => CycleTimeLocation2.amp,
                    2 => CycleTimeLocation2.speaker,
                    3 => CycleTimeLocation2.shuttle,
                    4 => CycleTimeLocation2.distance,

                    _ => CycleTimeLocation2.none,
                  },
                ),
              );

              break;
            
            // Climbing timer index. Make sure to update when moving around stuff!
            case 5:
              climbingTimerActive = !climbingTimerActive;
              break;
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

    return Expanded(
      child: ListView(
        children: [
          const Padding(padding: EdgeInsets.all(8)),

          buildTextNumberContainer(context, centeredWidthPadding, 3, "Match #", matchNum, matchNumberController),
          const Padding(padding: EdgeInsets.all(5)),
          buildTextNumberContainer(context, centeredWidthPadding, 5, "Team #", teamNum, teamNumberController),
          const Padding(padding: EdgeInsets.all(5)),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: centeredWidthPadding),

            child: FloatingToggleButton(
              initialColor: Theme.of(context).colorScheme.inversePrimary.withRed(255),
              pressedColor: Theme.of(context).colorScheme.inversePrimary,

              labelText: "Is Replay?",

              initialIcon: const Icon(Icons.close),
              pressedIcon: const Icon(Icons.check),

              onPressed: (value) => isReplay = value,
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

          const Padding(padding: EdgeInsets.all(5)),
          const Padding(padding: EdgeInsets.all(5)),

          const SubheaderLabel("Auto Mode"),

          createLabelAndCheckBox("Can Do It?", canDoAuto),
          createLabelAndNumberField("Scores", autoScores),
          createLabelAndNumberField("Misses", autoMisses),
          createLabelAndNumberField("Ejects", autoEjects),

          const Padding(padding: EdgeInsets.all(5)),
          const Padding(padding: EdgeInsets.all(5)),

          ExpansionTile(
            title: Text(
              "Cycles",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),

            collapsedBackgroundColor: Colors.grey.shade200,

            children: [
              SizedBox(
                width: centeredWidth,
                height: MediaQuery.of(context).size.height * 0.25,

                child: ListView.builder(
                  itemBuilder: (context, index) => buildCycleTile(context, index),
                  itemCount: cycles.length,
                ),
              ),
            ],
          ),

          const Padding(padding: EdgeInsets.all(8)),
          const Padding(padding: EdgeInsets.all(5)),

          const SubheaderLabel("Climbing"),
          
          Text(
            "${climbingTime.toStringAsPrecision(3)} secs",
            style: Theme.of(context).textTheme.labelLarge,
            textAlign: TextAlign.center,
          ),

          const Padding(padding: EdgeInsets.all(4)),

          createLabelAndCheckBox("Are They Successful?", canClimbSuccessfully),

          const Padding(padding: EdgeInsets.all(1.2)),

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

          const Padding(padding: EdgeInsets.all(6)),
          const Padding(padding: EdgeInsets.all(5)),

          const SubheaderLabel("Trap"),

          createLabelAndNumberField("Scores", trapScores),
          createLabelAndNumberField("Misses", trapMisses),

          const Padding(padding: EdgeInsets.all(5)),
          const Padding(padding: EdgeInsets.all(5)),

          const SubheaderLabel("Shooting Position (Speaker / Subwoofer)"),

          createLabelAndCheckBox("Middle", shootingPositionMiddle),
          createLabelAndCheckBox("Sides", shootingPositionSides),

          const Padding(padding: EdgeInsets.all(5)),
          const Padding(padding: EdgeInsets.all(5)),

          const SubheaderLabel("Pickup Locations"),

          createLabelAndCheckBox("Ground", pickupGround),
          createLabelAndCheckBox("Source", pickupSource),

          const Padding(padding: EdgeInsets.all(5)),
          const Padding(padding: EdgeInsets.all(5)),

          const SubheaderLabel("Misc."),

          createLabelAndCheckBox("Do They Park On The Stage?", endgamePark),
          createLabelAndCheckBox("Did Their Robot Get Disconnected Or Disabled?", disconnectOrDisabled),
          createLabelAndCheckBox("Did You Lose Track At Any Point?", scouterLostTrack),

          const Padding(padding: EdgeInsets.all(5)),
          const Padding(padding: EdgeInsets.all(5)),

          const SubheaderLabel("Notes"),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: centeredWidthPadding),

            child: TextField(
              controller: notesController,
              // Font needs to be 16 to fix IOS safari issue.
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
              onChanged: (value) => notes = value,
              maxLines: 10,

              decoration: const InputDecoration(
                  border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(1.0)),
                ),
                // contentPadding: EdgeInsets.symmetric(vertical: 125),
                isDense: false,
              ),
            ),
          ),  

          const Padding(padding: EdgeInsets.all(5)),
          const Padding(padding: EdgeInsets.all(12)),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85)),

            child: FloatingButton(
              labelText: "Save",
              icon: const Icon(Icons.save),
              color: Theme.of(context).colorScheme.inversePrimary,
              onPressed: () {
                App.promptAlert(
                  context,
                  "Save?",
                  "Are you sure you want to save and send this match form?\nThis action is currently irreversible.",
                  [
                    ("Yes", () {
                      if (
                        matchNum.value == "0" || 
                        teamNum.value == "0" ||
                        matchNum.value.isEmpty ||
                        teamNum.value.isEmpty
                      ) {
                        Navigator.of(context).pop();
                        App.showMessage(context, "You haven't fillied in the team number or match number.");
                        return;
                      }

                      addToMatchCache(toJson());
                      App.gotoPage(context, const HomePage());
                    }),
                    ("No", null),
                  ]
                );
              },
            ),
          ),

          const Padding(padding: EdgeInsets.all(16)),
        ],
      ),
    );
  }
  
  Widget buildCycleTile(BuildContext context, int index) {
    final info = cycles[index];

    return ListTile(
      title: Text("${info.time.toStringAsPrecision(3)} seconds"),

      subtitle: Text(info.location.toString()),

      leading: switch (info.location) {
        CycleTimeLocation2.amp => const Icon(Icons.amp_stories),
        CycleTimeLocation2.speaker => const Icon(Icons.speaker),
        CycleTimeLocation2.shuttle => const Icon(Icons.airport_shuttle),
        CycleTimeLocation2.distance => const Icon(Icons.social_distance),
        _ => const Icon(Icons.error),
      },

      onLongPress: () {
        App.promptAlert(
          context, 
          "Do You Want To Delete This Cycle Record?", 
          "time: ${info.time}, location: ${info.location}, success: ${info.success}", 
          [
            ("Yes", () {
              Navigator.of(context).pop();

              setState(() => cycles.removeAt(index));

              App.promptAction(
                context, 
                "Deleted Cycle Record", 
                "Undo?", 
                () { 
                  setState(() => cycles.insert(index, info));
                },
              );
            }),
            ("No", null),
          ],
        );
      },

      trailing: FloatingActionButton(
        heroTag: null,

        backgroundColor: info.success 
        ? Theme.of(context).colorScheme.inversePrimary
        : Theme.of(context).colorScheme.inversePrimary.withRed(255),

        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        disabledElevation: 0,
        highlightElevation: 0,

        onPressed: () =>
        setState(() {
          info.success = !info.success;
        }),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

        child: info.success
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
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
          onChanged: (value) => assigned.value = value,
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
        vertical: 8,
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
          vertical: 8),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
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
        vertical: 8,
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
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

  String toJson() {
    List<dynamic> expandCycles() {
      List<dynamic> result = [];

      for (final timestamp in cycles) {
        result.add(
          {
            "Time": timestamp.time,
            "Type": timestamp.location.toString(),
            "Success": timestamp.success,
          },
        );
      }

      if (cycles.isEmpty) {
        result.add(
          {
            "Time": 0,
            "Type": "None",
            "Success": false,
          }
        );
      }

      return result;
    }

    final result = jsonEncode(
		{
			"Team": teamNum.value.isEmpty ? 1 : int.parse(teamNum.value),
			"Match": {
				"Number": matchNum.value.isEmpty ? 1 : int.parse(matchNum.value),
				"isReplay": isReplay
			},

			"Driver Station": {
				"Is Blue": driverStation.value.$1,
				"Number": driverStation.value.$2
			},

			"Scouter": getScouterName(),

			"Cycles": expandCycles(),
      
      // TODO: Remove this.
			"Amp": false,
      // TODO: Remove this.
			"Speaker": false,

			"Speaker Positions": {
				"sides": shootingPositionSides.value,
				"middle": shootingPositionMiddle.value
			},

			"Pickup Locations": {
				"Ground": pickupGround.value,
				"Source": pickupSource.value,
			},

			"Distance Shooting": {
				"Can": false,
				"Misses": 0,
				"Scores": 0
			},

			"Auto": {
				"Can": canDoAuto.value,
				"Scores": autoScores.value,
				"Misses": autoMisses.value,
				"Ejects": autoEjects.value
			},

			"Climbing": {
				"Succeeded": canClimbSuccessfully.value,
				"Time": climbingTime
			},

			"Trap": {
				"Misses": trapMisses.value,
				"Score": trapScores.value
			},

			"Misc": {
				"Parked": endgamePark.value,
        // TODO: Remove one of these. Because having both is redundant.
				"Lost Communication": disconnectOrDisabled.value,
				"User Lost Track": scouterLostTrack.value,
        "Disabled": disconnectOrDisabled.value,
			},

			"Penalties": [

			],

      "Mangled": false,

			"Notes": notes
		}
    );

    log(result);

    return result;
  }
}