import 'package:flutter/material.dart';

class FloatingToggleButton extends StatefulWidget {
	const FloatingToggleButton(
		{
			super.key, 
			this.labelText, 
			this.initialColor, 
			this.initialIcon, 
			this.pressedColor, 
			this.pressedIcon,
			this.onPressed,
			this.initialValue = false,
			this.disabled = false,
		}
	);

	final String? labelText;

	final Color? initialColor;
	final Color? pressedColor;

	final Widget? initialIcon;
	final Widget? pressedIcon;

	final void Function(bool)? onPressed;

	final bool initialValue;
	final bool disabled;

	@override
	State<FloatingToggleButton> createState() => _FloatingToggleButton();
}

class _FloatingToggleButton extends State<FloatingToggleButton> {
	bool? wasClicked;

	void onPressed() {
		setState(() { 
			wasClicked = !wasClicked!;

			if (widget.onPressed != null && !widget.disabled) {
				widget.onPressed!(wasClicked!);
			}
		});
	}

	@override 
	Widget build(BuildContext context) {
		wasClicked ??= widget.initialValue;

		return FloatingActionButton(
			heroTag: null,

			backgroundColor: wasClicked! ? widget.pressedColor : widget.initialColor,

			onPressed: onPressed,

			child: Column(
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					Text(widget.labelText ?? ""),
					(wasClicked! ? widget.pressedIcon : widget.initialIcon) ?? const Icon(Icons.question_mark),
				],
			),
		);
	}
}