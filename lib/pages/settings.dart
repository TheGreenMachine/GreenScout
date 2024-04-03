import 'package:flutter/material.dart';
import 'package:green_scout/pages/navigation_layout.dart';
import 'package:green_scout/widgets/action_bar.dart';
import 'package:green_scout/widgets/header.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPage();  
}

class _SettingsPage extends State<SettingsPage> {
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
          const Padding(padding: EdgeInsets.all(4)),
          const HeaderLabel("Settings"),

          
        ],
      ),
    );
  }
}