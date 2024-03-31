import 'package:flutter/material.dart';
import 'package:green_scout/pages/navigation_layout.dart';

List<Widget> createDefaultActionBar() {
  return const [
    NavigationMenu(),
    Spacer(),
  ];
}

List<Widget> createEmptyActionBar() {
  return const [
    Spacer(),
  ];
}