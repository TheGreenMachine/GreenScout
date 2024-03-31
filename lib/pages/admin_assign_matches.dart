import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:green_scout/reference.dart';
import 'package:green_scout/widgets/dropdown.dart';
import 'package:green_scout/widgets/floating_button.dart';
import 'package:green_scout/widgets/number_counter.dart';
import 'package:green_scout/widgets/subheader.dart';
import 'package:green_scout/widgets/toggle_floating_button.dart';

class AdminAssignMatchesPage extends StatefulWidget {
	const AdminAssignMatchesPage({super.key});

	@override
	State<AdminAssignMatchesPage> createState() => _AdminAssignMatchesPage();
}

class MatchRangeInfo {
  const MatchRangeInfo(
    this.start,
    this.end,
    this.isBlue,
    this.driveTeamNumber,
  );

  final int start;
  final int end;
  final bool isBlue;
  final int driveTeamNumber;

  String toJson() {
    return jsonEncode([
      start,
      end,
      (isBlue ? 3 : 0) + driveTeamNumber,
    ]);
  }
}

class _AdminAssignMatchesPage extends State<AdminAssignMatchesPage> {
  static const noActiveUserSelected = "[[CURRENTLY NO ACTIVE USER IS SELECTED AT THIS MOMENT]]";

  Map<String, String> users = {
    "None": noActiveUserSelected,
  };

  Reference<String> currentUser = Reference(noActiveUserSelected);

  final fromTextController = TextEditingController();
  final toTextController = TextEditingController();

  bool isBlue = true;
  Reference<int> driverTeamNumber = Reference(1);

  List<MatchRangeInfo> matchesAssigned = [];

  @override
  void initState() {
    super.initState();

    // Some example test users
    // Display Name = Internal User ID
    users["Mr. Forrest"] = "mrf28";
    users["John Snow"] = "johns23";
    users["Sick Burn"] = "adamj29";
  }

  List<Widget> buildAssignmentFields(BuildContext context) {
    if (currentUser.value == noActiveUserSelected) {
      return [];
    }

    const matchRangeWidthRatio = 0.75;

    final matchRangeWidthPadding = MediaQuery.of(context).size.width * (1.0 - matchRangeWidthRatio) / 2;
    final matchRangeWidth = MediaQuery.of(context).size.width * matchRangeWidthRatio;

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
          initialColor: Colors.blue,
          initialIcon: const Text("BLUE"),
          pressedColor: Colors.red,
          pressedIcon: const Text("RED"),

          onPressed: (pressed) {
            isBlue = !pressed;
          },
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

            NumberCounterButton(number: driverTeamNumber, lowerBound: 1, upperBound: 3, widthRatio: 0.35,)
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
            if (
              fromTextController.text.isEmpty ||
              toTextController.text.isEmpty
            ) {
              return;
            } 

            matchesAssigned.add(
              MatchRangeInfo(
                int.parse(fromTextController.text),
                int.parse(toTextController.text),
                isBlue,
                driverTeamNumber.value,
              ),
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
            itemBuilder: (context, index) => buildAssignedMatchWidget(context, index, matchRangeWidth),
            itemCount: matchesAssigned.length,
          ),
        ),
      ),

      const Padding(padding: EdgeInsets.all(32)),
    ];
  } 

  Widget buildAssignedMatchWidget(BuildContext context, int index, double width) {
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
          matchesAssigned.removeAt(index);
          setState(() {});
        },

        child: const Icon(Icons.close, color: Colors.black87,),
      ),

      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      collapsedBackgroundColor: Theme.of(context).colorScheme.inversePrimary,
    );
  }

	@override 
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				backgroundColor: Theme.of(context).colorScheme.inversePrimary,

				actions: const [
					Spacer(),
				],
			),

			body: ListView(
				children: [
          const Padding(padding: EdgeInsets.all(8)),

          const SubheaderLabel("Users"),

          const Padding(padding: EdgeInsets.all(2)),

					Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (1.0 - 0.65) / 2),

            child: Dropdown<String>(
              padding: const EdgeInsets.only(left: 10),

              entries: users,
              inValue: currentUser,
              defaultValue: noActiveUserSelected,
              textStyle: null,

              alignment: Alignment.center,
              menuMaxHeight: 175,

              setState: () => setState(() {}),
            ),
          ),

          const Padding(padding: EdgeInsets.all(12)),

          ...buildAssignmentFields(context),
				],
			),
		);
	}
}