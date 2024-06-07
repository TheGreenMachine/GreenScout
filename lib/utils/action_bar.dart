import 'package:flutter/material.dart';
import 'package:green_scout/widgets/internet_indicator.dart';

/*
* A list of functions for creating action bars, it's really a reminent of an
* older design, but it wasn't ever properly ripped out. You can remove it if you want.
*
* This was mostly for before I had implemented the navigation drawer.
*
* - Michael.
*/

List<Widget> createDefaultActionBar() {
  return [
    const InternetIndicator(),
  ];
}

List<Widget> createEmptyActionBar() {
  return [
    const InternetIndicator(),
  ];
}