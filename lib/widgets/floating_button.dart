import 'package:flutter/material.dart';

/// A wrapper widget to easily create a button that can have both
/// an image and text at the same time.
class FloatingButton extends StatefulWidget {
	const FloatingButton({
		super.key, 
		this.onPressed, 
		this.icon, 
		this.color, 
		this.labelText,
		this.disabled = false,
		this.shadow = true,
	});

	final Widget? icon;
	final Color? color;
	final String? labelText;

	final void Function()? onPressed;
	final bool disabled;

	final bool shadow;

	@override
	State<FloatingButton> createState() => _FloatingButton();
}

class _FloatingButton extends State<FloatingButton> {
	void onPressed() {
		if (widget.onPressed != null && !widget.disabled) {
			widget.onPressed!();
		}
	}

	@override
	Widget build(BuildContext context) {
		final color = widget.color ?? const Color.fromARGB(255, 255, 255, 255);

		final disabledColor = Color.fromARGB(
			color.alpha,
			color.red ~/ 2,
			color.green ~/ 2,
			color.blue ~/ 2,
		);

		return FloatingActionButton(
			heroTag: null,

			backgroundColor: widget.disabled ? disabledColor : color,

			onPressed: onPressed,

			elevation: widget.shadow ? null : 0.0,
			focusElevation: widget.shadow ? null : 0.0,
			hoverElevation: widget.shadow ? null : 0.0,
			disabledElevation: widget.shadow ? null : 0.0,
			highlightElevation: widget.shadow ? null : 0.0,

			child: Column( 
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					if (widget.labelText != null) 
            Text(
              widget.labelText ?? "",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          
					if (widget.icon != null) 
            widget.icon!,
				],
			),
		);
	}
}