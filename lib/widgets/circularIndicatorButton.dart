import 'package:flutter/material.dart';

class CircularIndicatorButton extends StatelessWidget {
  const CircularIndicatorButton({Key? key, required this.isLeft, this.onTap})
      : super(key: key);

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
