import 'package:flutter/material.dart';
import 'package:green_scout/widgets/internet_indicator.dart';

List<Widget> createDefaultActionBar() {
  return [
    // NavigationMenuButton(),
    // const Spacer(),
    const InternetIndicator(),
  ];
}

List<Widget> createEmptyActionBar() {
  return [
    // const Spacer(),
    const InternetIndicator(),
  ];
}