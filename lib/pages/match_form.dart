
import 'package:green_scout/pages/preference_helpers.dart';
import 'package:green_scout/timer_button.dart';
import 'package:green_scout/widgets/floating_button.dart';
import 'package:green_scout/widgets/header.dart';
import 'package:green_scout/widgets/subheader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../globals.dart';
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

class Reference<T> {
  Reference(this.value);

  T value;
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
    this.location = CycleTimeLocationType.none,
  });

  double time;
  CycleTimeLocationType location;
}

class _MatchFormPage extends State<MatchFormPage> {
  final _matchController = TextEditingController();
  String matchNum = "";
  final _teamController = TextEditingController();
  String teamNum = "";
  bool isReplay = false;

  Reference<(bool, int)> driverStation = Reference((false, 1));

  final cycleWatch = Stopwatch();
  bool cycleStopwatchTimerValue = false;
  bool cycleTimerLocationDisabled = true;

  final climbingWatch = Stopwatch();
  double climbingTime = 0.0;

  Reference<bool> speakerSides = Reference(false);
  Reference<bool> speakerMiddle = Reference(false);

  Reference<bool> canShootIntoSpeaker = Reference(false);
  Reference<bool> canShootIntoAmp = Reference(false);

  Reference<bool> canDistanceShoot = Reference(false);
  Reference<int> distanceShootingScores = Reference(0);
  Reference<int> distanceShootingMisses = Reference(0);

  Reference<bool> canDoAuto = Reference(false);
  Reference<bool> succeededAuto = Reference(false);
  Reference<int> autoScoresNum = Reference(0);
  Reference<int> autoMissesNum = Reference(0);
  Reference<int> autoEjectsNum = Reference(0);

  Reference<int> trapMissesNum = Reference(0);
  Reference<int> trapScoreNum = Reference(0);

  Reference<bool> canPark = Reference(false);
  Reference<bool> disconnected = Reference(false);
  Reference<bool> lostTrack = Reference(false);

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

    _matchController.text = widget.matchNum ?? matchNum;
    _teamController.text = widget.teamNum ?? teamNum;

    _notesController.text = notes.value;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: const [
          NavigationMenu(),
          Spacer(),
        ],
      ),
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

                initialValue: isReplay,
              ),
            ),
          ],
        ),

        // TODO: Add an optional menu that appears when the user needs to properly
        // input a driver station value. (are they blue and what number are they).
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

        const Padding(padding: EdgeInsets.all(14)),

        createSectionHeader("Cycles"),

        createCycleTimers(ampColor, speakerColor),

        const Padding(padding: EdgeInsets.all(4)),

        createCycleListView(ampColor, speakerColor),

        const Padding(padding: EdgeInsets.all(16)),

        createSectionHeader("Shooting Info"),

        createLabelAndCheckBox("Shoots into Speaker?", canShootIntoSpeaker),
        createLabelAndCheckBox("Shoots into Amp?", canShootIntoAmp),

        const Padding(
          padding: EdgeInsets.all(16),
        ),

        createSectionHeader("Shooting Position (Speaker / Subwoofer)"),

        createLabelAndCheckBox("Middle", speakerMiddle),
        createLabelAndCheckBox("Sides", speakerSides),

        const Padding(padding: EdgeInsets.all(16)),

        createSectionHeader("Auto Mode"),

        createLabelAndCheckBox("Works?", canDoAuto),
        createLabelAndCheckBox("Successful?", succeededAuto),
        createLabelAndNumberField("Scores", autoScoresNum),
        createLabelAndNumberField("Misses", autoMissesNum),
        createLabelAndNumberField("Ejects", autoEjectsNum),

        const Padding(
          padding: EdgeInsets.all(14),
        ),

        createSectionHeader("Distance Shooting"),

        createLabelAndCheckBox("Can They Do It?", canDistanceShoot),
        createLabelAndNumberField("Scores", distanceShootingScores),
        createLabelAndNumberField("Misses", distanceShootingMisses),

        const Padding(padding: EdgeInsets.all(16)),

        createSectionHeader("Climbing"),

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
            )),

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

        createSectionHeader("Trap"),

        createLabelAndNumberField("Misses", trapMissesNum),
        createLabelAndNumberField("Scores", trapScoreNum),

        const Padding(padding: EdgeInsets.all(16)),

        createSectionHeader("Misc."),

        createLabelAndCheckBox("Do They Park?", canPark),
        createLabelAndCheckBox("Did They Disconnect?", disconnected),
        createLabelAndCheckBox("Did YOU Lose Track At Any Point?", lostTrack),

        // createLabelAndCheckBox("Do They Cooperate?", cooperates),

        const Padding(padding: EdgeInsets.all(24)),

        createSectionHeader("Notes"),

        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85)),
          child: TextField(
            controller: _notesController,
            style: Theme.of(context).textTheme.bodyMedium,
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

        FloatingButton(
          labelText: "Save",
          icon: const Icon(Icons.save),
          color: Theme.of(context).colorScheme.inversePrimary,
          onPressed: () {
            // final path = Uri(scheme: 'http', host: serverHostName, path: 'dataEntry', port: 3333);

            // http.post(path, headers: {}, body: toJson()).then((response) {
            // 	log("Response status: ${response.statusCode}");
            // 	log("Response body: ${response.body}");
            // }).catchError((error) { log(error.toString()); });

            addToMatchCache(toJson());
            Navigator.pushReplacementNamed(context, '/home');
          },
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
            initialValue: isReplay,
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
    // TODO: An interesting idea to pursue in the future is to make this and almost every little functio here
    // into individual stateful widgets so that only those that have anything modified actually update. Currently,
    // how we update for any little change can probably be a very bad thing that might bite us in terms of performance.

    if (number.value <= lowerBound) {
      number.value = lowerBound;
    }

    if (number.value >= upperBound) {
      number.value = upperBound;
    }

    final incrementButton = SizedBox(
      width: 65,
      height: 35,
      child: TextButton(
        style: ButtonStyle(
          textStyle:
              MaterialStateProperty.all(Theme.of(context).textTheme.labelLarge),
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return Theme.of(context).colorScheme.primary;
            }

            return Theme.of(context).colorScheme.inversePrimary;
          }),
          shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        ),
        onPressed: () {
          setState(() {
            number.value = number.value + 1;

            for (var increment in incrementChildren) {
              increment.value = increment.value + 1;
            }
          });
        },
        child: Text(number.value.toString()),
      ),
    );

    final decrementButton = SizedBox(
        width: 35,
        height: 35,
        child: TextButton(
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all(
                Theme.of(context).textTheme.titleLarge),
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.pressed)) {
                return Theme.of(context).colorScheme.primary.withRed(255);
              }

              return Theme.of(context).colorScheme.inversePrimary.withRed(255);
            }),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
            alignment: Alignment.center,
          ),
          onPressed: () {
            setState(() {
              number.value = number.value - 1;

              for (var decrement in decrementChildren) {
                decrement.value = decrement.value - 1;
              }
            });
          },
          child: const Text("-"),
        ));

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85),
          vertical: 5),
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
          SizedBox(
            width: 105,
            height: 35,
            child: Row(
              children: [
                decrementButton,
                const Padding(padding: EdgeInsets.symmetric(horizontal: 2.5)),
                incrementButton,
              ],
            ),
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
    List<DropdownMenuItem<V>> items = [];

    for (var entry in entries.entries) {
      items.add(
        DropdownMenuItem(
          value: entry.value,
          child: Text(
            entry.key,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85),
          vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          DropdownButton<V>(
            padding: const EdgeInsets.only(left: 5),
            items: items,
            value: inValue.value,
            onChanged: (newValue) => setState(() {
              inValue.value = newValue ?? defaultValue;
            }),
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
            onPressed: (pressed) => setState(() {
              cycleTimerLocationDisabled = !pressed;
              cycleStopwatchTimerValue = !cycleStopwatchTimerValue;

              // cycleWatch.reset();
              cycleWatch.start();

              if (!pressed) {
                cycleWatch.stop();
              }
            }),
            initialValue: cycleStopwatchTimerValue,
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
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width *
              (1.0 - 0.80) *
              MediaQuery.of(context).size.aspectRatio),
      child: SizedBox(
        width: 250,
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
                  width: 125,
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
                  width: 100,
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

                // SizedBox(
                // 	width: 25,
                // 	height: 35,

                // 	child: FloatingButton(
                // 		color: Theme.of(context).colorScheme.background,
                // 		icon: const Icon(Icons.remove_circle_outline_sharp),

                // 		shadow: false,

                // 		onPressed: () =>
                // 		setState(() {
                // 			timestamps.removeAt(index);
                // 		}),
                // 	),
                // )
              ],
            );
          },
        ),
      ),
    );
  }

  String toJson() {
    String expandCycles() {
      StringBuffer builder = StringBuffer();

      for (int i = 0; i < cycleTimestamps.length; i++) {
        builder.write(
          '{ "Time": ${cycleTimestamps[i].time}, "Type": "${cycleTimestamps[i].location}" }',
        );

        if (i != cycleTimestamps.length - 1) {
          builder.writeln(',');
        }
      }

      if (cycleTimestamps.isEmpty) {
        builder.write('{ "Time": 0, "Type": "None" }');
      }

      return builder.toString();
    }

    String scouterName = getScouterName();

    return '''
		{
			"Team": ${teamNum.isEmpty ? "1" : teamNum},
			"Match": {
				"Number": ${matchNum.isEmpty ? "1" : matchNum},
				"isReplay": $isReplay
			},

			"Driver Station": {
				"Is Blue": ${driverStation.value.$1},
				"Number": ${driverStation.value.$2}
			},

			"Scouter": "$scouterName",

			"Cycles": [
				${expandCycles()}
			],

			"Amp": ${canShootIntoAmp.value},
			"Speaker": ${canShootIntoSpeaker.value},

			"Speaker Positions": {
				"sides": ${speakerSides.value},
				"middle": ${speakerMiddle.value}
			},

			"Distance Shooting": {
				"Can": ${canDistanceShoot.value},
				"Misses": ${distanceShootingMisses.value},
				"Scores": ${distanceShootingScores.value}
			},

			"Auto": {
				"Can": ${canDoAuto.value},
				"Succeeded": ${succeededAuto.value},
				"Scores": ${autoScoresNum.value},
				"Misses": ${autoMissesNum.value},
				"Ejects": ${autoEjectsNum.value}
			},

			"Climbing": {
				"Can": ${climbingTime > 0.4},
				"Time": $climbingTime
			},

			"Trap": {
				"Misses": ${trapMissesNum.value},
				"Score": ${trapScoreNum.value} 
			},

			"Misc": {
				"Parked": ${canPark.value},
				"Lost Communication": ${disconnected.value},
				"User Lost Track": ${lostTrack.value}
			},

			"Penalties": [

			],

			"Notes": "${notes.value}"
		}
		''';
  }
}
