import 'package:flutter/material.dart';
import 'package:green_scout/pages/data_for_admins.dart';
import 'package:green_scout/reference.dart';
import 'package:green_scout/widgets/action_bar.dart';
import 'package:green_scout/widgets/dropdown.dart';
import 'package:green_scout/widgets/subheader.dart';

class GroupAdminAssignMatchesPage extends StatefulWidget {
  const GroupAdminAssignMatchesPage({
    super.key,
  });

  @override
  State<GroupAdminAssignMatchesPage> createState() => _GroupAdminAssignMatchesPage();
}

class _GroupAdminAssignMatchesPage extends State<GroupAdminAssignMatchesPage> {
  Reference<String> blue1User = Reference(AdminData.noActiveUserSelected);
  Reference<String> blue2User = Reference(AdminData.noActiveUserSelected);
  Reference<String> blue3User = Reference(AdminData.noActiveUserSelected);

  Reference<String> red1User = Reference(AdminData.noActiveUserSelected);
  Reference<String> red2User = Reference(AdminData.noActiveUserSelected);
  Reference<String> red3User = Reference(AdminData.noActiveUserSelected);

  @override
  void initState() {
    super.initState();

    AdminData.updateUserRoster();
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

  List<Widget> buildAssignmentList(BuildContext context) {
    for (var user in [ blue1User, blue2User, blue3User, red1User, red2User, red3User ]) {
      if (user.value == AdminData.noActiveUserSelected) {
        return [];
      }
    }

    return [
      const SubheaderLabel("Match Range"),
    ];
  }

  Widget buildUserDropdowns(BuildContext context, String message, Reference<String> user) {
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
            width: MediaQuery.of(context).size.width * (0.75) * 0.45,

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