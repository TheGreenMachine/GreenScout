import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:green_scout/main.dart';
import 'package:green_scout/utils/achievement_manager.dart';
import 'package:green_scout/utils/action_bar.dart';
import 'package:green_scout/utils/app_state.dart';
import 'package:green_scout/utils/general_utils.dart';
import 'package:green_scout/utils/reference.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    final (width, widthPadding) =
        screenScaler(MediaQuery.of(context).size.width, 670, 0.5, 1.0);

    var badges = buildAchievementsList(manager.leaderboardBadges, false);
    var other = buildAchievementsList(AchievementManager().silentBadges,
            false) + //why can you do list arithmatic lol
        buildAchievementsList(manager.textBadges, false);

    return Scaffold(
        drawer: const NavigationLayoutDrawer(),
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: createDefaultActionBar(),
          title: const Text("Achievements",
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: ListView(
          children: [
            const HeaderLabel("Achievements"),
            buildProgressBar(
                width, manager.getCompletionRatio(), "Achievements"),
            const Padding(padding: EdgeInsets.all(10)),
            SizedBox(
                height: 200,
                child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    children:
                        buildAchievementsList(manager.achievements, true))),
            if (badges.isNotEmpty) const HeaderLabel("Badges"),
            const Padding(padding: EdgeInsets.all(5)),
            SizedBox(
                height: 200,
                child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    children: badges)),
            if (other.isNotEmpty) const HeaderLabel("Other"),
            const Padding(padding: EdgeInsets.all(5)),
            SizedBox(
                height: 200,
                child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    children: other)),
          ],
        ));
  }

  Widget buildProgressBar(double width, double percent, String name) {
    return Center(
        child: LinearPercentIndicator(
      width: width,
      lineHeight: 20,
      percent: percent,
      backgroundColor: Colors.grey,
      progressColor: greenMachineGreen,
      alignment: MainAxisAlignment.center,
      barRadius: const Radius.circular(10),
      center: Text("$name ${(percent * 100).truncate()}% complete"),
      animateFromLastPercent: true,
      animation: true,
      animationDuration: 2000,
      curve: Curves.decelerate,
    ));
  }

  List<Widget> buildAchievementsList(
      Map<String, Achievement> achievements, bool unlockable) {
    List<Widget> built = List.empty(growable: true);

    achievements.forEach((key, value) {
      if (unlockable || value.met) {
        built.add(Padding(
            padding: const EdgeInsets.symmetric(),
            child: SizedBox(
                width: 250,
                height: 250,
                child: ExpansionTile(
                  title: FittedBox(
                      alignment: Alignment.topCenter,
                      fit: BoxFit.scaleDown,
                      child: value.met
                          ? value.badge
                          : const Icon(
                              Icons.lock_outline,
                              size: 100,
                            )),
                  subtitle: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: value.met
                          ? Text(
                              value.name,
                              textAlign: TextAlign.center,
                              textScaler: const TextScaler.linear(2),
                            ) //Nested ternaries i'm so sorry
                          : (value is PercentAchievement
                              ? buildProgressBar(
                                  200, value.percentCompletion.call(), "")
                              : const Text(
                                  "Condition not met",
                                  style: TextStyle(color: Colors.red),
                                ))),
                  children: [
                    Text(
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        value.met ? value.description : "Locked")
                  ],
                ))));
      }
    });
    return built;
  }
}
