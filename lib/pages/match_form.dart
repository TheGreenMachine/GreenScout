
import 'dart:convert';
import 'dart:developer';

import 'package:green_scout/pages/home.dart';
import 'package:green_scout/pages/preference_helpers.dart';
import 'package:green_scout/utils/reference.dart';
import 'package:green_scout/widgets/action_bar.dart';
import 'package:green_scout/widgets/dropdown.dart';
import 'package:green_scout/widgets/number_counter.dart';
import 'package:green_scout/widgets/timer_button.dart';
import 'package:green_scout/widgets/floating_button.dart';
import 'package:green_scout/widgets/header.dart';
import 'package:green_scout/widgets/subheader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:green_scout/utils/app_state.dart';
import 'navigation_layout.dart';
import '../widgets/toggle_floating_button.dart';
import 'dart:math' as math;

class MatchFormPage extends StatefulWidget {
  const MatchFormPage({
    super.key,
    this.matchNum,
    this.teamNum,
    this.isBlue = false,
    this.driverNumber = 1,
  });

  final String? matchNum;
  final String? teamNum;

  final bool isBlue;
  final int driverNumber;

  @override
  State<MatchFormPage> createState() => _MatchFormPage();
}

enum SpeakerPosition {
  top,
  middle,
  bottom;

  @override
  String toString() {
    return switch (this) {
      SpeakerPosition.top => "top",
      SpeakerPosition.middle => "middle",
      SpeakerPosition.bottom => "bottom",

      // ignore: unreachable_switch_case
      _ => "unknown",
    };
  }
}

enum CycleTimeLocationType {
  speaker,
  amp,

  none;

  @override
  String toString() {
    return switch (this) {
      CycleTimeLocationType.speaker => "Speaker",
      CycleTimeLocationType.amp => "Amp",
      _ => "None",
    };
  }
}

class CycleTimeInfo {
  CycleTimeInfo({
    this.time = 0.0,
    this.success = true,
    this.location = CycleTimeLocationType.none,
  });

  double time;
  bool success;
  CycleTimeLocationType location;
}

class _MatchFormPage extends State<MatchFormPage> {
  final _matchController = TextEditingController();
  String matchNum = "";
  final _teamController = TextEditingController();
  String teamNum = "";
  Reference<bool> isReplay = Reference(false);

  Reference<(bool, int)> driverStation = Reference((false, 1));

  final cycleWatch = Stopwatch();
  Reference<bool> cycleStopwatchTimerValue = Reference(false);
  bool cycleTimerLocationDisabled = true;

  Reference<bool> canClimbSuccessfully = Reference(false);
  final climbingWatch = Stopwatch();
  double climbingTime = 0.0;

  Reference<bool> speakerSides = Reference(false);
  Reference<bool> speakerMiddle = Reference(false);

  Reference<bool> canShootIntoSpeaker = Reference(false);
  Reference<bool> canShootIntoAmp = Reference(false);

  Reference<bool> canPickupGround = Reference(false);
  Reference<bool> canPickupSource = Reference(false);

  Reference<bool> canDistanceShoot = Reference(false);
  Reference<int> distanceShootingScores = Reference(0);
  Reference<int> distanceShootingMisses = Reference(0);

  Reference<bool> canDoAuto = Reference(false);
  Reference<int> autoScoresNum = Reference(0);
  Reference<int> autoMissesNum = Reference(0);
  Reference<int> autoEjectsNum = Reference(0);

  Reference<int> trapMissesNum = Reference(0);
  Reference<int> trapScoreNum = Reference(0);

  Reference<bool> canPark = Reference(false);
  Reference<bool> disconnected = Reference(false);
  Reference<bool> lostTrack = Reference(false);
  Reference<bool> disabled = Reference(false);

  final _notesController = TextEditingController();
  Reference<String> notes = Reference("");

  List<CycleTimeInfo> cycleTimestamps = [];
  int minTimestampsToDisplay = 10;

  final bufferTimeMs = 450;

  @override
  void dispose() {
    _matchController.dispose();
    _teamController.dispose();

    _notesController.dispose();

    super.dispose();
  }

  @override 
  void initState() {
    teamNum = widget.teamNum ?? "0";
    matchNum = widget.matchNum ?? "0";
	  driverStation.value = (widget.isBlue, widget.driverNumber);

	  super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;

    const mobileViewWidth = 450.0;

    Widget bodyContent;
    if (windowSize.width > mobileViewWidth) {
      bodyContent = buildDesktopView(context);
    } else {}

    // TODO: Finally create an appropriate Desktop view for the match form data.
    bodyContent = buildMobileView(context);

    _matchController.text = matchNum;
    _teamController.text = teamNum;

    _notesController.text = notes.value;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: createDefaultActionBar(),
      ),

      drawer: const NavigationLayoutDrawer(),
     
      body: bodyContent,
    );
  }

  Widget buildMobileView(BuildContext context) {
    final ampColor = Theme.of(context).colorScheme.inversePrimary.withRed(255);
    final speakerColor =
        Theme.of(context).colorScheme.inversePrimary.withBlue(255);

    return ListView(
      children: [
        const Padding(padding: EdgeInsets.all(8)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                SizedBox(
                  width: 150,
                  height: 35,
                  child: TextField(
                    controller: _matchController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: false),
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                    onChanged: (value) => matchNum = value,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: "Match #",
                      floatingLabelAlignment: FloatingLabelAlignment.center,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelStyle: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
                SizedBox(
                  width: 150,
                  height: 35,
                  child: TextFormField(
                    controller: _teamController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: false),
                    style: Theme.of(context).textTheme.titleMedium,
                    onChanged: (value) => teamNum = value,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(5),
                    ],
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: "Team #",
                      floatingLabelAlignment: FloatingLabelAlignment.center,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelStyle: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 6.5)),
            SizedBox(
              width: 75,
              height: 70,
              child: FloatingToggleButton(
                labelText: "Replay?",
                initialColor: greenMachineGreen.withRed(255),
                pressedColor: greenMachineGreen,
                initialIcon: const Icon(Icons.public_off_sharp),
                // initialIcon: const Text("NO"),
                pressedIcon: const Icon(Icons.public),
                // pressedIcon: const Text("YES"),
                onPressed: (_) {},

                inValue: isReplay,
              ),
            ),
          ],
        ),

        const Padding(padding: EdgeInsets.all(4)),

        createLabelAndDropdown<(bool, int)>(
          "Driver Station",
          {
            "Blue 1": (true, 1),
            "Blue 2": (true, 2),
            "Blue 3": (true, 3),
            "Red 1": (false, 1),
            "Red 2": (false, 2),
            "Red 3": (false, 3),
          },
          driverStation,
          (false, 1),
        ),

        const Padding(padding: EdgeInsets.all(10)),

        createSectionHeader("Auto Mode"),

        createLabelAndCheckBox("Can They Do It?", canDoAuto),
        createLabelAndNumberField("Scores", autoScoresNum),
        createLabelAndNumberField("Misses", autoMissesNum),
        createLabelAndNumberField("Ejects", autoEjectsNum),

        const Padding(padding: EdgeInsets.all(12)),
        
        
        createSectionHeader("Distance Shooting"),

        createLabelAndCheckBox("Can They Do It?", canDistanceShoot),
        createLabelAndNumberField("Scores", distanceShootingScores),
        createLabelAndNumberField("Misses", distanceShootingMisses),

        const Padding(padding: EdgeInsets.all(16)),



        createSectionHeader("Cycles"),

        createCycleTimers(ampColor, speakerColor),

        const Padding(padding: EdgeInsets.all(4)),

        createCycleListView(ampColor, speakerColor),

        const Padding(padding: EdgeInsets.all(16)),


        createSectionHeader("Climbing"),

        createLabelAndCheckBox("Was It Successful?", canClimbSuccessfully),

        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * (1.0 - 0.75)),
          child: TimerButton(
            height: 85,
            onEnd: (value) {
              climbingTime = value;
            },
            initialTime: climbingTime,
            lap: false,
          )
        ),

        // TODO: Reset button. I can't figure out how to make sure the
        // visual of the button to be reset too.

        // const Padding(padding: EdgeInsets.all(3)),

        // Padding(
        // 	padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (1.0 - 0.65)),

        // 	child: FloatingButton(
        // 		color: Theme.of(context).colorScheme.primaryContainer.withRed(255),

        // 		onPressed: () => setState(() {
        // 			climbingTime = 0.0;
        // 		}),

        // 		icon: const Icon(Icons.restore),
        // 	),
        // ),

        const Padding(padding: EdgeInsets.all(16)),



        createSectionHeader("Shooting Info"),

        createLabelAndCheckBox("Shoots into Speaker?", canShootIntoSpeaker),
        createLabelAndCheckBox("Shoots into Amp?", canShootIntoAmp),

        const Padding(padding: EdgeInsets.all(16)),


        

        createSectionHeader("Shooting Position (Speaker / Subwoofer)"),

        createLabelAndCheckBox("Middle", speakerMiddle),
        createLabelAndCheckBox("Sides", speakerSides),

        const Padding(padding: EdgeInsets.all(16)),



        createSectionHeader("Pickup Locations"),

        createLabelAndCheckBox("Ground", canPickupGround),
        createLabelAndCheckBox("Source", canPickupSource),

        const Padding(padding: EdgeInsets.all(16)),



        createSectionHeader("Trap"),

        createLabelAndNumberField("Misses", trapMissesNum),
        createLabelAndNumberField("Scores", trapScoreNum),

        const Padding(padding: EdgeInsets.all(16)),

        createSectionHeader("Misc."),

        createLabelAndCheckBox("Do They Park?", canPark),
        createLabelAndCheckBox("Did They Disconnect?", disconnected),
        createLabelAndCheckBox("Did YOU Lose Track At Any Point?", lostTrack),
        createLabelAndCheckBox("Did Their Robot Get Disabled?", disabled),

        // createLabelAndCheckBox("Do They Cooperate?", cooperates),

        const Padding(padding: EdgeInsets.all(24)),

        createSectionHeader("Notes"),

        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85),
          ),

          child: TextField(
            controller: _notesController,
            // Font needs to be 16 to fix IOS safari issue.
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
            onChanged: (value) => notes.value = value,
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

        const Padding(padding: EdgeInsets.all(24)),

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
                    if (matchNum == "0" || teamNum == "0") {
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

        // Extra padding for the bottom
        const Padding(padding: EdgeInsets.all(28)),
      ],
    );
  }

  Widget buildDesktopView(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.only(
            right: MediaQuery.of(context).size.width * (1 - 0.72),
            left: MediaQuery.of(context).size.width * (1 - 0.72),
            top: 25,
            bottom: 5,
          ),
          child: SizedBox(
            width: null,
            height: 40,
            child: TextField(
              controller: _matchController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: false),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: "Match #",
                floatingLabelAlignment: FloatingLabelAlignment.center,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelStyle: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * (1 - 0.72),
              vertical: 5),
          child: FloatingToggleButton(
            labelText: "Replay?",
            initialColor: greenMachineGreen.withRed(255),
            pressedColor: greenMachineGreen,
            initialIcon: const Icon(Icons.public_off_sharp),
            pressedIcon: const Icon(Icons.public),
            onPressed: (_) {},
            inValue: isReplay,
          ),
        ),
      ],
    );
  }

  Widget createSectionHeader(String headline) {
    return HeaderLabel(headline);
  }

  Widget createSubsectionHeader(String headline) {
    return SubheaderLabel(headline);
  }

  Widget createLabelAndCheckBox(String question, Reference<bool> condition) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85),
          vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * (1.0 * 0.55),
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
    // TODO: An interesting idea to pursue in the future is to make this and almost every little function here
    // into individual stateful widgets so that only those that have anything modified actually update. Currently,
    // how we update for any little change can probably be a very bad thing that might bite us in terms of performance.

    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85),
        vertical: 5,
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * (1.0 * 0.35),
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

  Widget createLabelAndDropdown<V>(
    String label,
    Map<String, V> entries,
    Reference<V> inValue,
    V defaultValue,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85),
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

  Widget createCycleTimers(Color ampColor, Color speakerColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 85,
          height: 50,
          child: FloatingButton(
            labelText: "Amp",
            icon: const Icon(Icons.amp_stories),
            color: ampColor,
            onPressed: () => setState(() {
              if (cycleWatch.elapsedMilliseconds < bufferTimeMs) {
                return;
              }

              cycleTimestamps.add(
                CycleTimeInfo(
                  time: cycleWatch.elapsedMilliseconds.toDouble() / 1000,
                  location: CycleTimeLocationType.amp,
                ),
              );
            }),
            disabled: cycleTimerLocationDisabled,
          ),
        ),
        SizedBox(
          width: 85,
          height: 50,
          child: FloatingToggleButton(
            labelText: "Start / Pause",
            initialIcon: const Icon(Icons.timer_sharp),
            pressedIcon: const Icon(Icons.timer),
            initialColor: Theme.of(context).colorScheme.primaryContainer,
            pressedColor: Theme.of(context).colorScheme.inversePrimary,
            onPressed: (pressed) {
              setState(() {
                cycleTimerLocationDisabled = !pressed;
                cycleStopwatchTimerValue.value = !cycleStopwatchTimerValue.value;

                // cycleWatch.reset();
                cycleWatch.start();

                if (!pressed) {
                  cycleWatch.stop();
                }
              });
              
              return null;
            },
            inValue: cycleStopwatchTimerValue,
          ),
        ),
        SizedBox(
          width: 85,
          height: 50,
          child: FloatingButton(
            labelText: "Speaker",
            icon: const Icon(Icons.speaker),
            color: speakerColor,
            onPressed: () => setState(() {
              if (cycleWatch.elapsedMilliseconds < bufferTimeMs) {
                return;
              }

              cycleTimestamps.add(
                CycleTimeInfo(
                  time: cycleWatch.elapsedMilliseconds.toDouble() / 1000,
                  location: CycleTimeLocationType.speaker,
                ),
              );
            }),
            disabled: cycleTimerLocationDisabled,
          ),
        ),
      ],
    );
  }

  Widget createCycleListView(Color ampColor, Color speakerColor) {
    const widthRatio = 0.85;

    final paddingWidth = MediaQuery.of(context).size.width * (1.0 - widthRatio);
    final width = MediaQuery.of(context).size.width * widthRatio;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: paddingWidth / 2,
      ),

      child: SizedBox(
        width: width,
        height: 200,
        child: ListView.builder(
          itemCount: math.max(minTimestampsToDisplay, cycleTimestamps.length),
          itemBuilder: (context, index) {
            CycleTimeInfo info;

            if (index > cycleTimestamps.length - 1) {
              info = CycleTimeInfo();
            } else {
              info = cycleTimestamps[index];
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: width * 0.435,
                  height: 35,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      info.time.toStringAsPrecision(3),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ),

                SizedBox(
                  width: width * 0.425,
                  height: 35,
                  child: Container(
                    alignment: Alignment.center,
                    color: switch (info.location) {
                      CycleTimeLocationType.amp => ampColor,
                      CycleTimeLocationType.speaker => speakerColor,
                      _ => Theme.of(context).colorScheme.inversePrimary,
                    },
                    child: Text(
                      info.location.toString(),
                      style: Theme.of(context).textTheme.labelMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                SizedBox(
                	width: width * 0.10,
                	height: 35,

                	child: FloatingActionButton(
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

                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),

                		child: info.success 
                    ? const Icon(Icons.check)
                    : const Icon(Icons.close),
                	),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  String toJson() {
    List<dynamic> expandCycles() {
      List<dynamic> result = [];

      for (final timestamp in cycleTimestamps) {
        result.add(
          {
            "Time": timestamp.time,
            "Type": timestamp.location.toString(),
            "Success": timestamp.success,
          },
        );
      }

      if (cycleTimestamps.isEmpty) {
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
			"Team": teamNum.isEmpty ? 1 : int.parse(teamNum),
			"Match": {
				"Number": matchNum.isEmpty ? 1 : int.parse(matchNum),
				"isReplay": isReplay.value
			},

			"Driver Station": {
				"Is Blue": driverStation.value.$1,
				"Number": driverStation.value.$2
			},

			"Scouter": getScouterName(),

			"Cycles": expandCycles(),

			"Amp": canShootIntoAmp.value,
			"Speaker": canShootIntoSpeaker.value,

			"Speaker Positions": {
				"sides": speakerSides.value,
				"middle": speakerMiddle.value
			},

			"Pickup Locations": {
				"Ground": canPickupGround.value,
				"Source": canPickupSource.value,
			},

			"Distance Shooting": {
				"Can": canDistanceShoot.value,
				"Misses": distanceShootingMisses.value,
				"Scores": distanceShootingScores.value
			},

			"Auto": {
				"Can": canDoAuto.value,
				"Scores": autoScoresNum.value,
				"Misses": autoMissesNum.value,
				"Ejects": autoEjectsNum.value
			},

			"Climbing": {
				"Succeeded": canClimbSuccessfully.value,
				"Time": climbingTime
			},

			"Trap": {
				"Misses": trapMissesNum.value,
				"Score": trapScoreNum.value
			},

			"Misc": {
				"Parked": canPark.value,
				"Lost Communication": disconnected.value,
				"User Lost Track": lostTrack.value,
        "Disabled": disabled.value,
			},

			"Penalties": [

			],

      "Mangled": false,

			"Notes": notes.value
		}
    );

    log(result);

    return result;
  }
}
