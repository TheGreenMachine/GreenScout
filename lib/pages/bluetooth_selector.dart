import 'package:flutter/material.dart';
import 'package:green_scout/pages/bluetooth_receiver.dart';
import 'package:green_scout/pages/bluetooth_sender.dart';
import 'package:green_scout/pages/navigation_layout.dart';
import 'package:green_scout/utils/bluetooth_utils.dart';
import 'package:green_scout/widgets/floating_button.dart';

class BluetoothSelectorPage extends StatelessWidget {
	const BluetoothSelectorPage({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				backgroundColor: Theme.of(context).colorScheme.inversePrimary,
				actions: const [
					NavigationMenu(),
					Spacer(),
				],
			),

			// body: isBTPermissionGivenSync() ? createBody(context) : createInvalidBody(context),
			body: createBody(context),
		);
	}

	// This is a body that will be created to present a view that the user cannot use bluetooth
	Widget createInvalidBody(BuildContext context) {
		return Padding(
			padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85)), 
			child: ListView(
				children: const [
					Padding(padding: EdgeInsets.all(8)),
					Icon(Icons.error_outline_sharp, size: 75,),

					Padding(padding: EdgeInsets.only(bottom: 12)),
					Text("It seems like you either don't have bluetooth enabled or the feature you're trying to use is unavailable for your device.",textAlign: TextAlign.center,),
				],
			),
		);
	}

	Widget createBody(BuildContext context) {
		return Padding( 
			padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85)), 

			child: ListView(
				children: [ 
					const Padding(padding: EdgeInsets.all(8)),

					FloatingButton(
						labelText: "Become A Receiver",

						icon: const Icon(Icons.receipt),
						color: Theme.of(context).colorScheme.inversePrimary.withBlue(255),
						onPressed: () => Navigator.pushReplacement(
							context,
							MaterialPageRoute(
								builder: (context) => const BluetoothReceiverPage(),
							),
						),
					),

					const Padding(padding: EdgeInsets.all(8)),

					FloatingButton(
						labelText: "Become A Sender",

						icon: const Icon(Icons.send),
						color: Theme.of(context).colorScheme.inversePrimary.withRed(255),
						onPressed: () => Navigator.pushReplacement(
							context,
							MaterialPageRoute(
								builder: (context) => const BluetoothSenderPage(),
							),
						),
					),
				],
			),
		);
	}
}