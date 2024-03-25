import 'package:ble_peripheral/ble_peripheral.dart';
import 'package:flutter/material.dart';
import 'package:green_scout/pages/navigation_layout.dart';
import 'package:green_scout/utils/bluetooth_utils.dart';

class BluetoothReceiverPage extends StatefulWidget {
	const BluetoothReceiverPage({super.key});

	@override
	State<BluetoothReceiverPage> createState() => _BluetoothReceiverPage();
}

class _BluetoothReceiverPage extends State<BluetoothReceiverPage> {
	@override
	void initState() {
		// Hack. force async to be sync.
		() async {
			await BlePeripheral.initialize();

			await BlePeripheral.addService(
				BleService(
					uuid: serviceUuid, 
					primary: true, 
					characteristics: [ 
						BleCharacteristic(
							uuid: characteristicUuid, 
							properties: [
								CharacteristicProperties.write.index,
							], 
							permissions: [
								AttributePermissions.writeable.index,
							]
						),
					],
				),
				timeout: const Duration(seconds: 15),
			);
		}();

		super.initState();
	}

	@override
	void deactivate() {
		() async {
			// no equivalent deinit for ble peripheral. Why...
		}();

		super.deactivate();
	}

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

			body: buildBody(context),
		);
	}

	Widget buildBody(BuildContext context) {
		return ListView(
			
		);
	}
}