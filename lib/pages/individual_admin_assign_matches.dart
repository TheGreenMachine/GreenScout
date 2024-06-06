import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:green_scout/utils/app_state.dart';
import 'package:green_scout/utils/data_for_admins.dart';
import 'package:green_scout/utils/reference.dart';
import 'package:green_scout/utils/action_bar.dart';
import 'package:green_scout/widgets/dropdown.dart';
import 'package:green_scout/widgets/floating_button.dart';
import 'package:green_scout/widgets/number_counter.dart';
import 'package:green_scout/widgets/subheader.dart';
import 'package:green_scout/widgets/toggle_floating_button.dart';

class IndividualAdminAssignMatchesPage extends StatefulWidget {
  const IndividualAdminAssignMatchesPage({super.key});

  @override
  State<IndividualAdminAssignMatchesPage> createState() =>
      _IndividualAdminAssignMatchesPage();
}

class IndividualMatchRangeInfo {
  const IndividualMatchRangeInfo(this.start, this.end, this.isBlue,
      this.driveTeamNumber, this.scouterName);

  final int start;
  final int end;
  final bool isBlue;
  final int driveTeamNumber;
  final String scouterName;

  String toJson() {
    return jsonEncode({
      "Ranges": [
        [
          start,
          end,
          (isBlue ? 3 : 0) + driveTeamNumber,
        ]
      ]
    });
  }
}

class _IndividualAdminAssignMatchesPage
    extends State<IndividualAdminAssignMatchesPage> {
  Reference<String> currentUser = Reference(AdminData.noActiveUserSelected);

  final fromTextController = TextEditingController();
  final toTextController = TextEditingController();

  Reference<bool> isBlue = Reference(true);
  Reference<int> driverTeamNumber = Reference(1);

  List<IndividualMatchRangeInfo> matchesAssigned = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdminData.updateUserRoster();
    });
  }

  @override
  void dispose() {
    fromTextController.dispose();
    toTextController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: createEmptyActionBar(),
      ),
      body: ListView(
        children: [
          const Padding(padding: EdgeInsets.all(8)),
          const SubheaderLabel("User"),
          const Padding(padding: EdgeInsets.all(2)),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * (1.0 - 0.65) / 2,
            ),
            child: Dropdown<String>(
              padding: const EdgeInsets.only(left: 10),
              isExpanded: true,
              entries: AdminData.users,
              inValue: currentUser,
              defaultValue: AdminData.noActiveUserSelected,
              textStyle: null,
              alignment: Alignment.center,
              menuMaxHeight: 175,
              setState: () => setState(() {}),
            )
          ),
          const Padding(padding: EdgeInsets.all(12)),
          ...buildAssignmentFields(context),
        ],
      ),
    );
  }

  Widget buildSendButton(BuildContext context, double widthPadding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widthPadding),
      child: FloatingButton(
        labelText: "Send To Server",
        color: Theme.of(context).colorScheme.inversePrimary,
        onPressed: () async {
          for (var match in matchesAssigned) {
            final success = await App.httpRequest("/addSchedule",
                match.toJson(), headers: {"userInput": match.scouterName});

            if (!success && context.mounted) {
              App.showMessage(context, "Failed To Send To Server!");
              return;
            }
          }

          matchesAssigned.clear();

          if (context.mounted) {
            App.showMessage(context, "Success!");
          }

          setState(() {});
        },
      ),
    );
  }

  List<Widget> buildAssignmentFields(BuildContext context) {
    if (currentUser.value == AdminData.noActiveUserSelected) {
      return [];
    }

    const matchRangeWidthRatio = 0.75;

    final matchRangeWidth =
        MediaQuery.of(context).size.width * matchRangeWidthRatio;

    final matchRangeWidthPadding =
        MediaQuery.of(context).size.width * (1.0 - matchRangeWidthRatio) / 2;

    return [
      const SubheaderLabel("Match Range"),
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: matchRangeWidthPadding,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: matchRangeWidth * 0.45,
              child: Text(
                "START",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            SizedBox(
              width: matchRangeWidth * 0.25,
              child: TextField(
                controller: fromTextController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
              ),
            ),
          ],
        ),
      ),
      const Padding(padding: EdgeInsets.all(4)),
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: matchRangeWidthPadding,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: matchRangeWidth * 0.45,
              child: Text(
                "END",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            SizedBox(
              width: matchRangeWidth * 0.25,
              child: TextField(
                controller: toTextController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
              ),
            ),
          ],
        ),
      ),
      const Padding(padding: EdgeInsets.all(16)),
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: matchRangeWidthPadding,
        ),
        child: FloatingToggleButton(
          pressedColor: Colors.blue,
          pressedIcon: const Text("BLUE"),
          initialColor: Colors.red,
          initialIcon: const Text("RED"),
          // onPressed: (pressed) {
          //   isBlue = !pressed;
          // },

          inValue: isBlue,
        ),
      ),
      const Padding(padding: EdgeInsets.all(4)),
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: matchRangeWidthPadding,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: matchRangeWidth * 0.45,
              child: Text(
                "DRIVE TEAM NUMBER",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            NumberCounterButton(
              number: driverTeamNumber,
              lowerBound: 1,
              upperBound: 3,
              widthRatio: 0.35,
            )
          ],
        ),
      ),
      const Padding(padding: EdgeInsets.all(18)),
      const SubheaderLabel("Add Match Range To List"),
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: matchRangeWidthPadding,
        ),
        child: FloatingButton(
          icon: const Icon(Icons.add),
          color: Theme.of(context).colorScheme.inversePrimary,
          onPressed: () {
            if (fromTextController.text.isEmpty ||
                toTextController.text.isEmpty) {
              return;
            }

            matchesAssigned.add(
              IndividualMatchRangeInfo(
                  int.parse(fromTextController.text),
                  int.parse(toTextController.text),
                  isBlue.value,
                  driverTeamNumber.value,
                  currentUser.value),
            );

            setState(() {});
          },
        ),
      ),
      const Padding(padding: EdgeInsets.all(4)),
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: matchRangeWidthPadding,
        ),
        child: SizedBox(
          width: matchRangeWidth,
          height: 240,
          child: ListView.builder(
            itemBuilder: (context, index) =>
                buildAssignedMatchWidget(context, index, matchRangeWidth),
            itemCount: matchesAssigned.length,
          ),
        ),
      ),
      const Padding(padding: EdgeInsets.all(16)),
      buildSendButton(context, matchRangeWidthPadding),
      const Padding(padding: EdgeInsets.all(32)),
    ];
  }

  Widget buildAssignedMatchWidget(
      BuildContext context, int index, double width) {
    final match = matchesAssigned[index];

    return ExpansionTile(
      title: Text("${match.start} - ${match.end}"),
      leading: Text(
        match.isBlue ? "B" : "R",
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        "Drive Team: ${match.driveTeamNumber}",
        style: Theme.of(context).textTheme.labelSmall,
      ),
      trailing: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent.shade400,
          elevation: 50,
        ),
        onPressed: () {
          final data = matchesAssigned.removeAt(index);

          App.promptAction(context, "Removed Assigned Match", "Undo?", () {
            matchesAssigned.insert(index, data);
            setState(() {});
          });

          setState(() {});
        },
        child: const Icon(
          Icons.close,
          color: Colors.black87,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      collapsedBackgroundColor: Theme.of(context).colorScheme.inversePrimary,
    );
  }
}
