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

		Color? color;

		if (widget.disabled) {
			final ensuredColor = widget.initialColor ?? const Color.fromARGB(255, 255, 255, 255);

			color = Color.fromARGB(
				ensuredColor.alpha,
				ensuredColor.red ~/ 2,
				ensuredColor.green ~/ 2,
				ensuredColor.blue ~/ 2,
			);
		} else {
			color = wasClicked! ? widget.pressedColor : widget.initialColor;
		}

		Widget? icon;

		if (widget.disabled) {
			icon = widget.initialIcon;
		} else {
			icon = wasClicked! ? widget.pressedIcon : widget.initialIcon;
		}

		if (widget.disabled) {
			if (wasClicked! && widget.onPressed != null) {
				widget.onPressed!(false);
			}

			wasClicked = false;
		}

		return FloatingActionButton(
			heroTag: null,

			backgroundColor: color,

			onPressed: onPressed,

			child: Column(
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					widget.labelText != null ? Text(
						widget.labelText ?? "",
						textAlign: TextAlign.center,
						style: Theme.of(context).textTheme.labelMedium,
					) : const Padding(padding: EdgeInsets.zero),
					icon ?? const Padding(padding: EdgeInsets.zero),
				],
			),
		);
	}
}