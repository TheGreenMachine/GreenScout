import 'package:flutter/material.dart';

/// A reusable widget for building navigation via arrow buttons.
/// 
/// Originally created by Tag, I don't know exactly why... - Michael
class CircularIndicatorButton extends StatelessWidget {
  const CircularIndicatorButton({super.key, required this.isLeft, this.onTap});

  final bool isLeft;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 32.0,
      height: 32.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Colors.white,
      ),
      child: Center(
        child: Icon(
          isLeft ? Icons.keyboard_arrow_left : Icons.keyboard_arrow_right,
          color: Colors.black,
          size: 30.0,
        ),
      ),
    ),
  );
}
