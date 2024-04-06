import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:green_scout/globals.dart';
import 'package:green_scout/pages/data_for_admins.dart';
import 'package:green_scout/pages/individual_admin_assign_matches.dart';
import 'package:green_scout/reference.dart';
import 'package:green_scout/widgets/action_bar.dart';
import 'package:green_scout/widgets/dropdown.dart';
import 'package:green_scout/widgets/floating_button.dart';
import 'package:green_scout/widgets/subheader.dart';

class GroupAdminAssignMatchesPage extends StatefulWidget {
  const GroupAdminAssignMatchesPage({
    super.key,
  });

  @override
  State<GroupAdminAssignMatchesPage> createState() =>
      _GroupAdminAssignMatchesPage();
}

class GroupMatchRangeInfo {
  const GroupMatchRangeInfo(
    this.start,
    this.end,
    this.userIds,
  );

  final int start;
  final int end;

  // It has to be of length 6.
  // 0-2 for red, 3-5 for blue
  final List<String> userIds;

  // 0-2 for blue, 3-5 for red
  String toJsonGeneric(int id) {
    return jsonEncode({
      "Ranges": [
        [
          start,
          end,
          id,
        ]
      ]
    });
  }
}

extension GroupMatchRangeInfoList on List<GroupMatchRangeInfo> {
  // 1-3 for red, 4-6 for blue
  String toJsonGeneric(int id) {
    List<List<int>> values = [];

    for (final match in this) {
      values.add([
        match.start,
        match.end,
        id,
      ]);
    }

    return jsonEncode(values);
  }
}

class _GroupAdminAssignMatchesPage extends State<GroupAdminAssignMatchesPage> {
  Reference<String> blue1User = Reference(AdminData.noActiveUserSelected);
  Reference<String> blue2User = Reference(AdminData.noActiveUserSelected);
  Reference<String> blue3User = Reference(AdminData.noActiveUserSelected);

  Reference<String> red1User = Reference(AdminData.noActiveUserSelected);
  Reference<String> red2User = Reference(AdminData.noActiveUserSelected);
  Reference<String> red3User = Reference(AdminData.noActiveUserSelected);

  final fromTextController = TextEditingController();
  final toTextController = TextEditingController();

  List<GroupMatchRangeInfo> matchesAssigned = [];

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
          const Padding(padding: EdgeInsets.all(12)),
          const SubheaderLabel("Blues"),
          const Padding(padding: EdgeInsets.all(2)),
          buildUserDropdowns(context, "BLUE 1", blue1User),
          const Padding(padding: EdgeInsets.all(2)),
          buildUserDropdowns(context, "BLUE 2", blue2User),
          const Padding(padding: EdgeInsets.all(2)),
          buildUserDropdowns(context, "BLUE 3", blue3User),
          const Padding(padding: EdgeInsets.all(16)),
          const SubheaderLabel("Reds"),
          buildUserDropdowns(context, "RED 1", red1User),
          const Padding(padding: EdgeInsets.all(2)),
          buildUserDropdowns(context, "RED 2", red2User),
          const Padding(padding: EdgeInsets.all(2)),
          buildUserDropdowns(context, "RED 3", red3User),
          const Padding(padding: EdgeInsets.all(16)),
          ...buildAssignmentList(context),
          const Padding(padding: EdgeInsets.all(32)),
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
        onPressed: () {
          for (var match in matchesAssigned) {
            for (var i = 0; i < match.userIds.length; i++) {
              App.httpPostWithHeaders("addSchedule", match.toJsonGeneric(i),
                  MapEntry("userInput", match.userIds[i]));
            }
          }

          App.showMessage(context, "Success!");
          setState(() {});
        },
      ),
    );
  }

  List<Widget> buildAssignmentList(BuildContext context) {
    for (var user in [
      blue1User,
      blue2User,
      blue3User,
      red1User,
      red2User,
      red3User
    ]) {
      if (user.value == AdminData.noActiveUserSelected) {
        return [];
      }
    }

    const matchRangeWidthRatio = 0.75;

    final matchRangeWidthPadding =
        MediaQuery.of(context).size.width * (1.0 - matchRangeWidthRatio) / 2;
    final matchRangeWidth =
        MediaQuery.of(context).size.width * matchRangeWidthRatio;

    return [
      const SubheaderLabel("Match Range"),
      const Padding(padding: EdgeInsets.all(2)),
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
              GroupMatchRangeInfo(
                int.parse(fromTextController.text),
                int.parse(toTextController.text),
                [
                  blue1User.value,
                  blue2User.value,
                  blue3User.value,
                  red1User.value,
                  red2User.value,
                  red3User.value,
                ],
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

    StringBuffer firstTwoLetters = StringBuffer();

    for (final userId in match.userIds) {
      AdminData.users.forEach((key, value) {
        if (value == userId) {
          firstTwoLetters.write(key.substring(0, 2));
          firstTwoLetters.write(" ");

          return;
        }
      });
    }

    return ExpansionTile(
      title: Text("${match.start} - ${match.end}"),
      leading: Text(
        "G",
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        firstTwoLetters.toString(),
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

  Widget buildUserDropdowns(
      BuildContext context, String message, Reference<String> user) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * (1.0 - 0.75) / 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            message,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * (0.75) * 0.55,
            child: Dropdown<String>(
              isExpanded: true,
              entries: AdminData.users,
              inValue: user,
              defaultValue: AdminData.noActiveUserSelected,
              textStyle: null,
              alignment: AlignmentDirectional.center,
              setState: () => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }
}
