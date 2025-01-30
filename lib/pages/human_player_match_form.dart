import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:green_scout/utils/app_state.dart';
import 'package:green_scout/pages/home.dart';
import 'package:green_scout/widgets/navigation_layout.dart';
import 'package:green_scout/utils/main_app_data_helper.dart';
import 'package:green_scout/utils/reference.dart';
import 'package:green_scout/utils/action_bar.dart';
import 'package:green_scout/widgets/dropdown.dart';
import 'package:green_scout/widgets/floating_button.dart';
import 'package:green_scout/widgets/number_counter.dart';
import 'package:green_scout/widgets/subheader.dart';
import 'package:green_scout/widgets/toggle_floating_button.dart';

/// The main bread and butter of the app. 
/// 
/// This is where everything related to the actual scouting is stored.
/// It's best to describe this as monolithic page that contains a whole toolset.
/// 
/// This page __will__ get updated overtime and as such, I'd recommend
/// storing branches to the previous years versions. That way you can reference
/// and take what you like UI-wise. 
/// 
/// I expect this part to have stuff ripped out when it makes sense to not have
/// it anymore. So, feel free to absolutely demolish this and start from scrtach
/// when it makes sense to. - Michael. 
class HumanScoutingForm extends StatefulWidget {
  const HumanScoutingForm({
    super.key,
    this.teamNumB,
    this.teamNumR,
    this.matchNum,
    this.isBlue,
    this.autoNumber,
  });

  final String? matchNum;
  final String? teamNumB;
  final String? teamNumR;
  final bool? isBlue;
  final int? autoNumber;

  @override
  State<HumanScoutingForm> createState() => _HumanScoutingForm();
}

/// A simple enum to store the multiple
/// locations where a team can shoot.
enum CycleTimeLocation {
  amp,
  speaker,
  shuttle,
  distance,

  none;

  @override
  String toString() {
    return switch (this) {
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

/// A simple class to store data related to 
/// a "cycle", which can be thought of as 
/// "how long does it take to pick up and
/// shoot a note."
class CycleTimeInfo {
  CycleTimeInfo({
    this.time = 0.0,
    this.success = false,
    this.location = CycleTimeLocation.none,
  });

  double time;
  bool success;
  CycleTimeLocation location;
}

class _HumanScoutingForm extends State<HumanScoutingForm> {
  /// This will most likely never go away. Because I doubt
  /// there won't be drivestations in the future.
  Reference<int> autoNumber = Reference(1);

  /* 
  * I also highly doubt that the items below will be going away.
  * Especially since they aren't really season specific.
  */

  Reference<bool> isReplay = Reference(false);
  Reference<bool> isRescout = Reference(false);
  Reference<String> matchNum = Reference("");
  Reference<String> teamNumB = Reference("");
  Reference<String> teamNumR = Reference("");
  String notes = "";

  TextEditingController matchNumberController = TextEditingController();
  TextEditingController teamNumberControllerBlue = TextEditingController();
  TextEditingController teamNumberControllerRed = TextEditingController();
  TextEditingController notesController = TextEditingController();

  /* START OF SEASON SPECIFIC INFORMATION */

  Reference<int> netScoresB = Reference(0);
  Reference<int> netMissesB = Reference(0);
  Reference<int> netScoresR = Reference(0);
  Reference<int> netMissesR = Reference(0);  
  Stopwatch climbingStopwatch = Stopwatch();
  double climbingTime = 0.0;
  bool climbingTimerActive = false;

  Reference<bool> scouterLostTrack = Reference(false);

  /* END OF SEASON SPECIFIC INFORMATION */

  @override
  void initState() {
    super.initState();

    matchNum.value = widget.matchNum ?? "0";
    teamNumB.value = widget.teamNumB ?? "0";
    teamNumR.value = widget.teamNumR ?? "0";

    autoNumber.value = (-1);
  }

  @override
  Widget build(BuildContext context) {

    teamNumberControllerBlue.text = teamNumB.value;
    teamNumberControllerRed.text = teamNumR.value;
    notesController.text = notes;

    Widget mainContent = buildMainContent(context);


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: createDefaultActionBar(),
      ),
      drawer: const NavigationLayoutDrawer(),
      body: Row(
        children: [
          mainContent
        ],
      ),
    );
  }

  Widget buildMainContent(BuildContext context) {
    const widthRatio = 0.85;

    final widthPadding =
        MediaQuery.of(context).size.width * (1.0 - widthRatio) / 2;

    return Expanded(
      child: ListView(
        children: [

          const Padding(padding: EdgeInsets.all(10)),

          buildTextNumberContainer(
            context,
            widthPadding,
            3,
            "",
            "Match #",
            matchNum,
            matchNumberController,
          ),

          const Padding(padding: EdgeInsets.all(11)),

                    defaultTargetPlatform == TargetPlatform.iOS
              ? buildSaveButton(context, widthPadding)
              : const Padding(
                  padding: EdgeInsets.zero,
          ),  // This is to allow an out for the ios users out there.

          const Padding(padding: EdgeInsets.all(10)),
          const SubheaderLabel("Red Player"),

          const Padding(padding: EdgeInsets.all(8)),
          // buildTextNumberContainerSmall(
          //   context,
          //   widthPadding,
          //   5,
          //   "Team Number",
          //   "",
          //   teamNumR,
          //   teamNumberControllerRed,
          // ),

          createLabelAndNumberField("Scores", netScoresR),
          createLabelAndNumberField("Misses", netMissesR),

          const Padding(padding: EdgeInsets.all(10)),
          const SubheaderLabel("Blue Player"),

          const Padding(padding: EdgeInsets.all(8)),
          
          buildTextNumberContainer(
            context,
            widthPadding,
            5,
            "",
            "Enter Team Number",
            teamNumB,
            teamNumberControllerBlue
          ),

          createLabelAndNumberField("Scores", netScoresB),
          createLabelAndNumberField("Misses", netMissesB),

          const Padding(padding: EdgeInsets.all(10)),
          const SubheaderLabel("Misc."),

          createLabelAndCheckBox(
            "Did You Lose Track At Any Point?",
            scouterLostTrack,
          ),

          const Padding(padding: EdgeInsets.all(10)),

          const SubheaderLabel("Notes"),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: widthPadding),
            child: TextField(
              controller: notesController,
              // NOTE: Font needs to be greater than 16 to fix IOS safari issue.
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 18),

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

          const Padding(padding: EdgeInsets.all(17)),

          Settings.enableMatchRescouting.value()
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: widthPadding),
                  child: FloatingToggleButton(
                    initialColor: Theme.of(context)
                        .colorScheme
                        .inversePrimary
                        .withRed(
                            App.getThemeMode() == Brightness.dark ? 225 : 255),
                    pressedColor: Theme.of(context).colorScheme.inversePrimary,
                    labelText: "Rescouting?",
                    initialIcon: const Icon(Icons.close),
                    pressedIcon: const Icon(Icons.check),
                    inValue: isRescout,
                    onPressed: (pressed) {
                      if (pressed) {
                        App.promptAlert(
                          context,
                          "Are you sure you're rescouting this match?",
                          "This flag when submitted with \"Save\" is irreversible.",
                          [
                            (
                              "Yes",
                              () {
                                isRescout.value = pressed;
                                Navigator.of(context).pop();
                              }
                            ),
                            (
                              "No",
                              () {
                                setState(() {
                                  isRescout.value = false;
                                });
                                Navigator.of(context).pop();
                              }
                            ),
                          ],
                        );
                      }
                    },
                  ),
                )
              : const Padding(padding: EdgeInsets.zero),

          const Padding(padding: EdgeInsets.all(4)),

          defaultTargetPlatform == TargetPlatform.iOS
              ? const Padding(padding: EdgeInsets.zero)
              : buildSaveButton(context, widthPadding),

          const Padding(padding: EdgeInsets.all(16)),
        ],
      ),
    );
  }

  Widget buildSaveButton(BuildContext context, double widthPadding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widthPadding),
      child: FloatingButton(
        labelText: "Save",
        icon: const Icon(Icons.save),
        color: Theme.of(context).colorScheme.inversePrimary,
        onPressed: () {
          App.promptAlert(
              context,
              "Save?",
              "Are you sure you want to save and send this scouting form?\nThis action is currently irreversible.",
              [
                (
                  "Yes",
                  () {
                    if (matchNum.value == "0" ||
                        matchNum.value.isEmpty || 
                        teamNumR.value == "0" ||
                        teamNumR.value.isEmpty ||
                        teamNumB.value == "0" ||
                        teamNumB.value.isEmpty) {
                      Navigator.of(context).pop();
                      App.showMessage(context,
                          "You haven't filled in the team number or match number.");
                      return;
                    }
                    MainAppData.addToMatchCache(toJson());
                    App.gotoPage(context, const HomePage());
                  }
                ),
                ("No", null),
              ]);
        },
      ),
    );
  }

  Widget buildTextNumberContainer(
    BuildContext context,
    double widthPadding,
    int digitLimit,
    String hint,
    String label,
    Reference<String> assigned,
    TextEditingController controller,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widthPadding),
      child: SizedBox(
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
            hintText: hint,
            labelText: label,
            floatingLabelAlignment: FloatingLabelAlignment.start,
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
        vertical: 8,
      ),
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
    final result = jsonEncode({
      "Red Team": teamNumR.value.isEmpty ? 1 : int.parse(teamNumR.value),
      "Blue Team": teamNumB.value.isEmpty ? 1 : int.parse(teamNumB.value),
      "Scouter": MainAppData.scouterName,
      
    });

    log("Exported Json:\n------------------------------\n$result\n------------------------------");

    return result;
  }
}
