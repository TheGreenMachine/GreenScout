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
class PitScoutingPage extends StatefulWidget {
  const PitScoutingPage({
    super.key,
    this.teamNum,
    this.isBlue,
    this.autoNumber,
    this.gearRatio,
    this.cycleTime,
    this.autoCount,
    this.weightBumper,
    this.endgamePreference
  });

  final String? teamNum;
  final String? autoCount;
  final String? gearRatio;
  final String? cycleTime;
  final String? weightBumper;
  final bool? isBlue;
  final int? autoNumber;
  final int? endgamePreference;

  @override
  State<PitScoutingPage> createState() => _PitScoutingPage();
}

class _PitScoutingPage extends State<PitScoutingPage> {
  /// This will most likely never go away. Because I doubt
  /// there won't be drivestations in the future.

  /* 
  * I also highly doubt that the items below will be going away.
  * Especially since they aren't really season specific.
  */

  Reference<bool> isReplay = Reference(false);
  Reference<bool> isRescout = Reference(false);
  Reference<bool> driveTrainType = Reference(false);
  Reference<String> teamNum = Reference("");
  Reference<String> autoNumber = Reference("");
  Reference<String> weightBumper = Reference("");
  Reference<String> autoCount = Reference("");
  Reference<String> cycleTime = Reference("");
  Reference<String> gearRatio = Reference("");
  Reference<String> favoritePart = Reference("");
  Reference<String> prefRobot = Reference("");

  String notes = "";

  TextEditingController matchNumberController = TextEditingController();
  TextEditingController teamNumberController = TextEditingController();
  TextEditingController weightBumperController = TextEditingController();
  TextEditingController autoCountController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  TextEditingController cycleTimeController = TextEditingController();
  TextEditingController favoritePartController = TextEditingController();
  TextEditingController prefRobotController = TextEditingController();
  TextEditingController gearRatioController = TextEditingController();

  /* START OF SEASON SPECIFIC INFORMATION */

  Reference<bool> canClimbSuccessfully = Reference(false);

  Reference<bool> canDoAuto = Reference(false);
  Reference<bool> dynamicAuto = Reference(false);


  Reference<bool> canL1 = Reference(false);
  Reference<bool> canL2 = Reference(false);
  Reference<bool> canL3 = Reference(false);
  Reference<bool> canL4 = Reference(false);

  Stopwatch climbingStopwatch = Stopwatch();
  double climbingTime = 0.0;
  bool climbingTimerActive = false;

  Reference<bool> pickupGround = Reference(false);
  Reference<bool> pickupSource = Reference(false);

  Reference<bool> knocksL2Algae = Reference(false); 
  Reference<bool> knocksL3Algae = Reference(false); 
  Reference<bool> pickupAGround = Reference(false); //A for Algae
  Reference<bool> pickupASource = Reference(false);
  Reference<bool> robotNet = Reference(false);
  Reference<bool> canProcess= Reference(false);   

  Reference<int> driverExp = Reference(0);
  Reference<int> teleopPreference = Reference(-1);


  Reference<bool> endgamePark = Reference(false);
  Reference<int> endgamePreference = Reference(1);
  Reference<bool> climbsDeep = Reference(false);
  Reference<bool> climbsShallow = Reference(false);

  /* END OF SEASON SPECIFIC INFORMATION */

  @override
  void initState() {
    super.initState();

    teamNum.value = widget.teamNum ?? "0";
    weightBumper.value = widget.weightBumper ?? "0";
    autoCount.value = widget.autoCount ?? "0";
    gearRatio.value = widget.gearRatio ?? "0";
    cycleTime.value = widget.cycleTime ?? "0";
  }

  @override
  Widget build(BuildContext context) {

    teamNumberController.text = teamNum.value; 
    weightBumperController.text = weightBumper.value;
    autoCountController.text = autoCount.value;
    gearRatioController.text = gearRatio.value;
    cycleTimeController.text = cycleTime.value;
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
          const Padding(padding: EdgeInsets.all(8)),

          const Padding(padding: EdgeInsets.all(5)),

          buildTextNumberContainer(
            context,
            widthPadding,
            5,
            "Team #",
            teamNum,
            teamNumberController,
          ),
          const Padding(padding: EdgeInsets.all(10)),

          buildTextNumberContainer(
            context,
            widthPadding,
            5,
            "Weight w/ Bumpers",
            weightBumper,
            weightBumperController,
          ),
          const Padding(padding: EdgeInsets.all(5)),

          const SubheaderLabel("Autos"),

          const Padding(padding: EdgeInsets.all(6)),

          buildTextNumberContainer(
            context,
            widthPadding,
            5,
            "# of Autos",
            autoCount,
            autoCountController,
          ),
          const Padding(padding: EdgeInsets.all(2)),
          createLabelAndCheckBox("Dynamic Auto?", dynamicAuto),
          
          const Padding(padding: EdgeInsets.all(6)),

          const SubheaderLabel("Drive Motor"),

          const Padding(padding: EdgeInsets.all(6)),

          buildTextNumberContainer(
            context,
            widthPadding,
            5,
            "Gear Ratio?",
            gearRatio,
            gearRatioController,
          ),

          createLabelAndDropdown<bool>(
            "Drive Train Type",
            {
              "Swerve Drive": true,
              "Tank Drive" : false,
            },
            driveTrainType,
            false,
          ),

          defaultTargetPlatform == TargetPlatform.iOS
              ? buildSaveButton(context, widthPadding)
              : const Padding(
                  padding: EdgeInsets.zero,
          ),  // This is to allow an out for the ios users out there.

          const Padding(padding: EdgeInsets.all(10)),

          const SubheaderLabel("Coral"),

          createLabelAndCheckBox("L1/Trough?", canL1),
          createLabelAndCheckBox("L2?", canL2),
          createLabelAndCheckBox("L3?", canL3),
          createLabelAndCheckBox("L4?", canL4),

          const Padding(padding: EdgeInsets.all(10)),
          const SubheaderLabel("Coral Pickup Locations"),

          createLabelAndCheckBox("Ground", pickupGround),
          createLabelAndCheckBox("Source", pickupSource),

          const Padding(padding: EdgeInsets.all(10)),
          const SubheaderLabel("Algae"),

          createLabelAndCheckBox("Can Knock Off L2 Algae?", knocksL2Algae),
          createLabelAndCheckBox("Can Knock Off L3 Algae?", knocksL3Algae),
          createLabelAndCheckBox("Can Use The Processor?", canProcess),
          createLabelAndCheckBox("Can The Robot Throw Into The Net?", robotNet),   

          const Padding(padding: EdgeInsets.all(10)),
          const SubheaderLabel("Algae Pickup Locations"),

          createLabelAndCheckBox("Ground", pickupAGround),
          createLabelAndCheckBox("Source", pickupASource),       

          const Padding(padding: EdgeInsets.all(10)),
          const SubheaderLabel("Driver"),
          const Padding(padding: EdgeInsets.all(6)),
          buildTextNumberContainer(
            context,
            widthPadding,
            5,
            "Average Cycle Time?",
            cycleTime,
            cycleTimeController,
          ),
          const Padding(padding: EdgeInsets.all(6)),
          createLabelAndNumberField("Driver Years of Experience", driverExp),          
          createLabelAndDropdown<int>(
            "Preferred Teleop",
            {
              "No Preference": -1,
              "Scoring Trough": 1,
              "Scoring L2": 2,
              "Scoring L3": 3,
              "Scoring L4": 4,
              "Scoring Processor": 5,
              "Scoring Net": 6,              
              "Knocking Algae": 7,
            },
            teleopPreference,
            -1,
          ), 

          const Padding(padding: EdgeInsets.all(10)),

          const SubheaderLabel("Endgame"),
          createLabelAndDropdown<int>(
            "Preferred Endgame",
            {
              "No Preference": -1,
              "Keep Scoring Coral": 1,
              "Play Defense": 2,
              "Park In The Barge": 3,
              "Climb Shallow Cage": 4,
              "Climb Deep Cage": 5,
              "Keep Scoring Algae": 6,
            },
            endgamePreference,
            -1,
          ),  
          createLabelAndCheckBox("Can Climb Shallow?", climbsShallow),
          createLabelAndCheckBox("Can Climb Deep?", climbsDeep),        

          const Padding(padding: EdgeInsets.all(10)),

          const SubheaderLabel("Misc."),     
          const Padding(padding: EdgeInsets.all(4)),
          buildTextContainer(
            context,
            widthPadding,
            200,
            "What Type of Robot Would Compliment You Best?",
            prefRobot,
            prefRobotController,
          ),
          const Padding(padding: EdgeInsets.all(10)),
          buildTextContainer(
            context,
            widthPadding,
            200,
            "Favorite Part of The Robot? ",
            favoritePart,
            favoritePartController,
          ),
          const SubheaderLabel("Notes"),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: widthPadding),
            child: TextField(
              controller: notesController,
              // NOTE: Font needs to be greater than 16 to fix IOS safari issue.
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 17),

              onChanged: (value) => notes = value,
              maxLines: 10,

              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
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
                    if (teamNum.value == "0" ||
                        teamNum.value.isEmpty) {
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
            labelText: label,
            floatingLabelAlignment: FloatingLabelAlignment.start,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            labelStyle: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
    );
  }

  Widget buildTextContainer(
    BuildContext context,
    double widthPadding,
    int lenLimit,
    String label,
    Reference<String> assigned,
    TextEditingController controller,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widthPadding),
      child: SizedBox(
        height: 96,
        child: TextField(
          maxLines: 3,
          controller: controller,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.left,
          onChanged: (value) => assigned.value = value,
          inputFormatters: [
            LengthLimitingTextInputFormatter(lenLimit),
          ],
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
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
      "Team": teamNum.value.isEmpty ? 1 : int.parse(teamNum.value),
      "Scouter": MainAppData.scouterName,

      "Weight": weightBumper.value.isEmpty ? -1 : int.parse(weightBumper.value),
      "Auto": {
        "Number of Autos": autoCount.value.isEmpty ? -1 : int.parse(autoCount.value),
        "Dynamic Auto": dynamicAuto.value,
      },
      "Drive": {
        "Gear Ratio": gearRatio.value.isEmpty ? "idk" : gearRatio.value,
        "Drive Train": driveTrainType.value ? "Tank Drive" : "Swerve Drive",
      },
      "Coral" :{
        "L1": canL1.value,
        "L2": canL2.value,
        "L3": canL3.value,    
        "L4": canL4.value,
        "Coral Ground Pickup": pickupGround.value,
        "Coral Source Pickup": pickupSource.value,
      },
      "Algae" :{
        "L2": knocksL2Algae.value,
        "L3": knocksL3Algae.value,
        "Can Net": robotNet.value,    
        "Can Processor": canProcess.value,
        "Algae Ground Pickup": pickupAGround.value,
        "Algae Source Pickup": pickupASource.value,
      },
      "Driver": {
        "Avg. Cycle Time": cycleTime.value.isEmpty ? -1 : int.parse(cycleTime.value),
        "Driver Years of Experience": driverExp.value,
        "Preferred Teleop": teleopPreference.value, 
      },
      "Endgame": {
        "Preferred Endgame": endgamePreference.value,
        "Can Climb Shallow Cage": climbsShallow.value,
        "Can Climb Deep Cage": climbsDeep.value,        
      },
      "Misc.": {
      "What Type of Robot Would Compliment You Best?" : prefRobot.value,
      "Favorite Part of the Robot?" : favoritePart.value,
      "Notes" : notes,  
      }

      
    });

    log("Exported Json:\n------------------------------\n$result\n------------------------------");

    return result;
  }
}
