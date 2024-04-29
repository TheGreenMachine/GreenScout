import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:green_scout/utils/app_state.dart';
import 'package:green_scout/utils/reference.dart';
import 'package:green_scout/widgets/action_bar.dart';
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
    double widthRatio = 1.0;

    const ratioThresold = 670;

    {
      final width = MediaQuery.of(context).size.width;

      final percent = clampDouble(((width - ratioThresold) / (ratioThresold)), 0.0, 1.0);

      widthRatio = (1.0 - 0.50 * percent);
    }

    final width = MediaQuery.of(context).size.width * widthRatio;
    final widthPadding = MediaQuery.of(context).size.width * (1.0 - widthRatio) / 2;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: createEmptyActionBar(),
      ),

      body: ListView(
        children: [
          const HeaderLabel("Match Form Layout"),
          const Padding(padding: EdgeInsets.all(6)),

          createLabelAndDropdown<bool>(
            "Side Bar Position", 
            {
              "Left": true,
              "Right": false,
            }, 
            Settings.sideBarLeftSided, 
            false,
          ),

          createLabelAndDropdown<bool>(
            "Number Counter Decrement Position", 
            {
              "Left": false,
              "Right": true,
            },
            Settings.flipNumberCounter,
            false,
          ),

          // I didn't think about how much more work this might cause me.
          // I don't want to maintain two different match form layouts right now...
          // createLabelAndCheckBox("Use Old Match Form Layout?", Settings.useOldLayout),

          const Padding(padding: EdgeInsets.all(20)),
          const SubheaderLabel("Advanced Features"),
          const Padding(padding: EdgeInsets.all(6)),

          createLabelAndCheckBox("Enable Match Rescouting?", Settings.enableMatchRescouting),
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
        horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85) / 2,
        vertical: 8,
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.65,

            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
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
          vertical: 8),

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