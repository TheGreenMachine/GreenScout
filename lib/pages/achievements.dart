import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:green_scout/utils/achievement_manager.dart';
import 'package:green_scout/utils/action_bar.dart';
import 'package:green_scout/utils/app_state.dart';
import 'package:green_scout/utils/general_utils.dart';
import 'package:green_scout/utils/main_app_data_helper.dart';
import 'package:green_scout/widgets/header.dart';
import 'package:green_scout/widgets/navigation_layout.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPage();
}

class _AchievementsPage extends State<AchievementsPage> {
  @override
  void initState() {
    super.initState();

    () async {
      await App.httpRequest("/userInfo", "", onGet: (response) {
        var responseJson = jsonDecode(response.body);

        if (!AchievementManager.isCheating()) {
          AchievementManager.syncAchievements(
              responseJson["Badges"], responseJson["Accolades"]);
        }
      }, headers: {
        "username": MainAppData.scouterName,
        "uuid": MainAppData.userUUID
      });

      setState(() {});
    }();
  }

  @override
  Widget build(BuildContext context) {
    final (width, widthPadding) =
        screenScaler(MediaQuery.of(context).size.width, 670, 0.5, 1.0);

    return Scaffold(
      drawer: const NavigationLayoutDrawer(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: createDefaultActionBar(),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const Padding(padding: EdgeInsets.all(10)),
          buildAchievementsList(context, AchievementManager.achievements,
              "Achievements", true, width, widthPadding, true),
          buildAchievementsList(context, AchievementManager.leaderboardBadges,
              "Badges", false, width, widthPadding, false),
          buildAchievementsList(context, AchievementManager.silentBadges,
              "Other", false, width, widthPadding, false),
        ],
      ),
    );
  }

  Widget buildProgressBar(double width, double percent) {
    return Center(
      child: LinearPercentIndicator(
        width: width,
        lineHeight: 20,
        percent: percent,
        backgroundColor: Colors.grey,
        progressColor: greenMachineGreen,
        alignment: MainAxisAlignment.center,
        barRadius: const Radius.circular(10),
        center: Text("${(percent * 100).truncate()}% complete"),
        animateFromLastPercent: true,
        animation: true,
        animationDuration: 2000,
        curve: Curves.decelerate,
      ),
    );
  }

  List<Widget> buildUnlocksLayout(BuildContext context, Achievement achievement,
      double width, double widthPadding) {
    return [
      const Padding(padding: EdgeInsets.all(36)),
      const Text(
        "Unlocks",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
      const Padding(padding: EdgeInsets.all(5)),
      Text(
        achievement.unlocks!,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    ];
  }

  void showInfoPopup(BuildContext context, Achievement achievement,
      double width, double widthPadding) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: widthPadding, vertical: 60),
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(padding: EdgeInsets.all(6)),
                Text(
                  achievement.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 34,
                  ),
                ),
                const Padding(padding: EdgeInsets.all(20)),
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: achievement.badge,
                ),
                const Padding(padding: EdgeInsets.all(6)),
                Text(
                  achievement.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    // fontStyle: FontStyle.italic,
                  ),
                ),
                if (achievement.unlocks != null)
                  ...buildUnlocksLayout(
                      context, achievement, width, widthPadding),
                const Padding(padding: EdgeInsets.all(16)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildAchievementsList(
      BuildContext context,
      List<Achievement> achievements,
      String header,
      bool unlockable,
      double width,
      double widthPadding,
      bool displayProgressBar) {
    final built = <Widget>[];

    for (final value in achievements) {
      if (!unlockable && !value.met) {
        continue;
      }

      if (value.ref != null) {
        value.met = value.ref!.value;
      }

      built.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7),
          child: Stack(
            children: [
              if (value.showDescription && value.met)
                const Positioned(
                  left: 5,
                  top: 5,
                  child: Icon(
                    Icons.info_outlined,
                    size: 20,
                    color: Colors.grey,
                  ),
                ),
              InkWell(
                // Weird hack, but what this does is make it so the button
                // doesn't have a clickable state when it doesn't have a description.
                // - Michael
                onTap: !(value.showDescription && value.met)
                    ? null
                    : () {
                        showInfoPopup(context, value, width, widthPadding);
                      },

                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    // TODO: Might need a better way to scale this. It looks odd with some items on smaller screens. - Michael.
                    minHeight: width / 4,
                    minWidth: width / 4,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      color: App.getThemeMode() == Brightness.light
                          ? Colors.grey.shade100
                          : Colors.grey.shade600,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: value.met
                                ? value.badge
                                : const Icon(Icons.lock_outline, size: 80),
                          ),
                          const Padding(padding: EdgeInsets.all(4)),
                          Text(
                            buildCompletionMessage(value),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        if (built.isNotEmpty) HeaderLabel(header, bold: true),
        if (displayProgressBar)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: buildProgressBar(
                width, AchievementManager.getCompletionRatio()),
          ),
        const Padding(padding: EdgeInsets.all(8)),
        Wrap(
          spacing: 2,
          alignment: WrapAlignment.center,
          children: built.map((element) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
              ),
              child: element,
            );
          }).toList(),
        ),
        const Padding(padding: EdgeInsets.all(16)),
      ],
    );
  }

  static String buildCompletionMessage(Achievement achievement) {
    if (achievement is PercentAchievement) {
      return achievement.met
          ? achievement.name
          : "${(achievement.percentCompletion.call() * 100).truncate()}%";
    }
    return achievement.met ? achievement.name : "?";
  }
}
