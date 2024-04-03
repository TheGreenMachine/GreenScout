import 'package:flutter/material.dart';
import 'package:green_scout/globals.dart';
import 'package:green_scout/pages/navigation_layout.dart';

List<Widget> createDefaultActionBar() {
  return [
    // NavigationMenuButton(),
    // const Spacer(),
    App.internetOff ? const Padding( 
      padding: EdgeInsets.only(right: 10),
      child: Icon(Icons.wifi_off, color: Colors.red),
    ) : const Padding(padding: EdgeInsets.zero),
  ];
}

List<Widget> createEmptyActionBar() {
  return [
    // const Spacer(),
    App.internetOff ? const Icon(Icons.wifi_off, color: Colors.red,) : const Padding(padding: EdgeInsets.zero),
  ];
}