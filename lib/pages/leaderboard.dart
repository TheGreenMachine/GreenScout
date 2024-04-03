import 'package:flutter/material.dart';
import 'package:green_scout/pages/navigation_layout.dart';
import 'package:green_scout/widgets/action_bar.dart';
import 'package:green_scout/widgets/header.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPage();
} 

class _LeaderboardPage extends State<LeaderboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        actions: createDefaultActionBar(),
      ),

      drawer: const NavigationLayoutDrawer(),

      body: ListView(
        children: [
          const HeaderLabel("Leaderboard"),
        ],
      ),
    );
  }
}