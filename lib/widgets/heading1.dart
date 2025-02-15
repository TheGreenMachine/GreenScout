import 'package:flutter/material.dart';

/// A reusable widget for easily creating subheader or smaller text on a page.
class Heading1Label extends StatelessWidget {
	const Heading1Label(this.labelText, {super.key});

	final String labelText;

	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85), vertical: 5),

			child: Text(
				labelText,
				style: Theme.of(context).textTheme.titleSmall,
				textAlign: TextAlign.left,
			),
		);
	}
}