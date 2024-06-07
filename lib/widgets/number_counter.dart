import 'package:flutter/material.dart';
import 'package:green_scout/utils/app_state.dart';
import 'package:green_scout/utils/reference.dart';

/// A widget that encapsulates reusable behavior for incrementing
/// and decrementing a referenced number. 
/// 
/// NOTE: Mainly used in the pages/match_form.dart page, but is used 
/// elsewhere since the logical was useful in other situations. - Michael
class NumberCounterButton extends StatefulWidget {
  const NumberCounterButton({
    super.key,

    required this.number,

    this.incrementChildren = const [],
    this.decrementChildren = const [],

    this.lowerBound = 0,
    this.upperBound = 99,

    this.widthRatio = 0.25,
  });

  final Reference<int> number;

  final List<Reference<int>> incrementChildren;
  final List<Reference<int>> decrementChildren;

  final int lowerBound;
  final int upperBound;

  /// The percentage of the screen the total element will take up.
  final double widthRatio;

  @override
  State<NumberCounterButton> createState() => _NumberCounterButton();
}

class _NumberCounterButton extends State<NumberCounterButton> {
  static const double buttonRadius = 7.5;

  Widget buildIncrementButton(BuildContext context, double width) {
    return SizedBox(
      width: width * 0.58,
      height: 35,
      child: TextButton(
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all(
            Theme.of(context).textTheme.labelLarge,
          ),

          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return Theme.of(context).colorScheme.primary;
            }

            return Theme.of(context).colorScheme.inversePrimary;
          }),

          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(buttonRadius),
            ),
          ),
        ),
        
        onPressed: () {
          setState(() {
            widget.number.value = widget.number.value + 1;

            for (var increment in widget.incrementChildren) {
              increment.value = increment.value + 1;
            }
          });
        },

        child: Text(widget.number.value.toString()),
      ),
    );
  }

  Widget buildDecrementButton(BuildContext context, double width) {
    return SizedBox(
      width: width * 0.39,
      height: 35,
      child: TextButton(
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all(
            Theme.of(context).textTheme.titleLarge,
          ),

          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return Theme.of(context).colorScheme.primary.withRed(255);
            }

            return Theme.of(context).colorScheme.inversePrimary.withRed(255);
          }),

          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(buttonRadius),
            ),
          ),

          alignment: Alignment.center,
        ),

        onPressed: () {
          setState(() {
            widget.number.value = widget.number.value - 1;

            for (var decrement in widget.decrementChildren) {
              decrement.value = decrement.value - 1;
            }
          });
        },

        child: const Text("-", textAlign: TextAlign.center,),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final widthRatio = widget.widthRatio;

    final width = MediaQuery.of(context).size.width * widthRatio;
    // final widthPadding = MediaQuery.of(context).size.width * (1.0 - widthRatio) / 2;

    if (widget.number.value <= widget.lowerBound) {
      widget.number.value = widget.lowerBound;
    }

    if (widget.number.value >= widget.upperBound) {
      widget.number.value = widget.upperBound;
    }

    Widget decrementButton = buildDecrementButton(context, width);
    Widget incrementButton = buildIncrementButton(context, width);

    Widget leftWidget = Settings.flipNumberCounter.value() 
    ? incrementButton
    : decrementButton;

    Widget rightWidget = Settings.flipNumberCounter.value()
    ? decrementButton
    : incrementButton;

    return SizedBox(
      width: width,
      height: 35,
      child: Row(
        children: [
          leftWidget,
          Padding(padding: EdgeInsets.symmetric(horizontal: width * 0.01)),
          rightWidget,
        ],
      ),
    );
  }
}