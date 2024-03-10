import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberField extends StatelessWidget {
	const NumberField({super.key, this.hintText, this.width, this.height, this.numberLengthLimit, this.onChange});

	final double? width;
	final double? height;
	final String? hintText;
	final int? numberLengthLimit;

	final void Function(String)? onChange;

	void handleNumberInput(String input) {
	}

	@override 
	Widget build(BuildContext context) {
		return SizedBox(
			width: width,
			height: height,
			child: TextField(
				keyboardType: TextInputType.number,
				onChanged: handleNumberInput,
				textAlign: TextAlign.center,
				style: Theme.of(context).textTheme.bodyLarge,

				inputFormatters: [
					// FilteringTextInputFormatter.digitsOnly,
					FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
					LengthLimitingTextInputFormatter(numberLengthLimit),
				],
				decoration: InputDecoration(
					// border: const OutlineInputBorder(),
					hintText: hintText,
					// floatingLabelAlignment: FloatingLabelAlignment.center,
					// labelText: hintText,
					// labelStyle: TextStyle(height: height),
				),
			)
		);
	}
}