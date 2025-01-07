import 'package:flutter/material.dart';
import 'package:green_scout/main.dart';
import 'package:green_scout/utils/app_state.dart';
import 'package:green_scout/utils/general_utils.dart';
import 'package:green_scout/utils/main_app_data_helper.dart';
import 'package:green_scout/utils/reference.dart';
import 'package:green_scout/utils/action_bar.dart';
import 'package:green_scout/widgets/dropdown.dart';
import 'package:green_scout/widgets/header.dart';
import 'package:green_scout/widgets/subheader.dart';

class themesPage extends StatefulWidget {
  const themesPage({
    super.key, 
  });

  @override
  State<themesPage> createState() =>
      _themesPage();
}

class _themesPage extends State<themesPage> {
  @override
  
  Reference<int> themeNum = Reference(1);

  Widget build(BuildContext context) {
    final (width, widthPadding) =
        screenScaler(MediaQuery.of(context).size.width, 670, 0.95, 0.95);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: createEmptyActionBar(),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: widthPadding),
        child: ListView(
          children: [
            const HeaderLabel("Themes"),
            const Padding(padding: EdgeInsets.all(6)),
              createLabelAndDropdown<int>(
                "Theme Pallete",
                widthPadding,
                width,
                {
                  "Dark": 1,
                  "Green": 2,
                  "Blue": 3,                                    
                },
                themeNum,
                2,
              ),
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
              onChanged: () {
                if (!(App.getBool("Detective") ?? false)) {
                  MainAppData.triggerDetective(context);
                }
              },
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

  Widget createLabelAndCheckBox(
      String question, double widthPadding, Reference<bool> condition) {
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
              if (!(App.getBool("Detective") ?? false)) {
                MainAppData.triggerDetective(context);
              }
            }),
          ),
        ],
      ),
    );
  }

  
}
