import 'package:flutter/material.dart';
import 'package:green_scout/reference.dart';
import 'package:green_scout/widgets/dropdown.dart';
import 'package:green_scout/widgets/floating_button.dart';
import 'package:green_scout/widgets/subheader.dart';

class AdminAssignMatchesPage extends StatefulWidget {
	const AdminAssignMatchesPage({super.key});

	@override
	State<AdminAssignMatchesPage> createState() => _AdminAssignMatchesPage();
}

class _AdminAssignMatchesPage extends State<AdminAssignMatchesPage> {
  static const noActiveUserSelected = "[[CURRENTLY NO ACTIVE USER IS SELECTED AT THIS MOMENT]]";

  Map<String, String> users = {
    "None": noActiveUserSelected,
  };

  Reference<String> currentUser = Reference(noActiveUserSelected);

  final fromTextController = TextEditingController();
  final toTextController = TextEditingController();

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
                "Start",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            
            SizedBox(
              width: matchRangeWidth * 0.25,

              child: TextField(
                controller: fromTextController,
                textAlign: TextAlign.center,
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
                "End",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            
            SizedBox(
              width: matchRangeWidth * 0.25,

              child: TextField(
                controller: toTextController,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    ];
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