import 'package:flutter/material.dart';
import 'package:green_scout/utils/app_state.dart';
import 'package:green_scout/utils/general_utils.dart';
import 'package:green_scout/utils/reference.dart';
import 'package:green_scout/utils/action_bar.dart';
import 'package:green_scout/widgets/dropdown.dart';
import 'package:green_scout/widgets/header.dart';
import 'package:green_scout/widgets/subheader.dart';

class SettingsMatchFormLayoutPage extends StatefulWidget {
  const SettingsMatchFormLayoutPage({
    super.key,
  });

  @override
  State<SettingsMatchFormLayoutPage> createState() => _SettingsMatchFormLayoutPage();
}

class _SettingsMatchFormLayoutPage extends State<SettingsMatchFormLayoutPage> {
  @override
  Widget build(BuildContext context) {
    final (width, widthPadding) = screenScaler(MediaQuery.of(context).size.width, 670, 0.95, 0.95);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: createEmptyActionBar(),
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: widthPadding),

        child: ListView(
          children: [
            const HeaderLabel("Match Form Layout"),
            const Padding(padding: EdgeInsets.all(6)),

            createLabelAndDropdown<bool>(
              "Side Bar Position", 
              widthPadding,
              width,
              {
                "Left": true,
                "Right": false,
              }, 
              Settings.sideBarLeftSided.ref, 
              false,
            ),

            createLabelAndDropdown<bool>(
              "Number Counter Decrement Position", 
              widthPadding,
              width,
              {
                "Left": false,
                "Right": true,
              },
              Settings.flipNumberCounter.ref,
              false,
            ),

            // I didn't think about how much more work this might cause me.
            // I don't want to maintain two different match form layouts right now...
            // createLabelAndCheckBox("Use Old Match Form Layout?", Settings.useOldLayout),

            const Padding(padding: EdgeInsets.all(20)),
            const SubheaderLabel("Advanced Features"),
            const Padding(padding: EdgeInsets.all(6)),

            createLabelAndCheckBox("Enable Match Rescouting?", widthPadding, Settings.enableMatchRescouting.ref),
          ],
        ),
      ),
    );
  }

  Widget createLabelAndDropdown<V>(
    String label,
    double widthPadding,
    double width,
    Map<String, V> entries,
    Reference<V> inValue,
    V defaultValue,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widthPadding,
        vertical: 8,
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: width * 0.65,

            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          SizedBox(
            width: width * 0.25,

            child: Dropdown<V>(
              entries: entries,
              inValue: inValue,
              defaultValue: defaultValue,
              textStyle: Theme.of(context).textTheme.labelMedium,
              padding: const EdgeInsets.only(left: 5),
            ),
          ),
        ],
      ),
    );
  }

  Widget createLabelAndCheckBox(String question, double widthPadding, Reference<bool> condition) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widthPadding,
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
}