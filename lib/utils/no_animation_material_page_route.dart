import 'package:flutter/material.dart';

/// Implementation taken from this stackoverflow answer:
/// https://stackoverflow.com/a/53503738
/// 
/// This little class helps us to switch between pages without an annoying animation playing.
class NoAnimationMaterialPageRoute<T> extends MaterialPageRoute<T> {
  NoAnimationMaterialPageRoute({
    required super.builder,
    super.settings,
    super.maintainState,
    super.fullscreenDialog,
  });

  @override
  Widget buildTransitions(
    BuildContext context, 
    Animation<double> animation,
    Animation<double> secondaryAnimation, 
    Widget child,
  ) => child;
}