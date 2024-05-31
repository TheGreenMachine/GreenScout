import 'package:flutter/material.dart';

class HeaderLabel extends StatelessWidget {
	const HeaderLabel(this.labelText, {super.key, this.bold=false});

	final String labelText;
  final bool bold;

	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85), vertical: 5),

			child: Text(
				labelText,
				style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: bold ? FontWeight.bold : FontWeight.normal),
				textAlign: TextAlign.center,
			),
		);
	}
}