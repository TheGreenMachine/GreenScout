import 'package:flutter/material.dart';
import 'number_field.dart';

class NumberLabelField extends StatelessWidget {
	const NumberLabelField({super.key, this.labelText, this.hintText, this.height, this.width, this.numberLengthLimit, this.onChanged});

	final double? width;
	final double? height;

	final String? hintText;
	final String? labelText;

	final int? numberLengthLimit;
	final void Function(String)? onChanged;

	@override 
	Widget build(BuildContext context) {
		const paddingAmount = 2;

		return SizedBox(
			width: width,
			height: height,

			child: Row(
				children: [
					SizedBox( 
						width: (width ?? 1) / 2,
						height: height,
						child: FittedBox( 
							fit: BoxFit.fitHeight,
							alignment: Alignment.centerRight,
							child: Text(
								(labelText ?? "").padRight((labelText?.length ?? 0) + paddingAmount),
								textAlign: TextAlign.left,
								style: Theme.of(context).textTheme.labelMedium,
								// textHeightBehavior: const TextHeightBehavior(),
								// textScaler: TextScaler.linear(((width ?? 1) / 2) / (height ?? 1)),
							),
						),
					),
					const Spacer(flex: 1,),
					NumberField(width: (width ?? 1) / 2, height: height, hintText: hintText, numberLengthLimit: numberLengthLimit, onChange: onChanged,),
				],
			)
		);
	}
}