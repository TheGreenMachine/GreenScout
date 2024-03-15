import 'package:flutter/material.dart';

class HeaderLabel extends StatelessWidget {
	const HeaderLabel(this.labelText, {super.key});

	final String labelText;

	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85), vertical: 5),

			child: Text(
				labelText,
				style: Theme.of(context).textTheme.headlineSmall,
				textAlign: TextAlign.center,
			),
		);
	}
}