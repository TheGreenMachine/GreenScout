import 'dart:convert';

import 'package:ble_peripheral/ble_peripheral.dart';
import 'package:flutter/material.dart';
import 'package:green_scout/pages/navigation_layout.dart';
import 'package:green_scout/utils/bluetooth_utils.dart';
import 'package:green_scout/widgets/toggle_floating_button.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothSenderPage extends StatefulWidget {
  const BluetoothSenderPage({super.key});

  @override
  State<BluetoothSenderPage> createState() => _BluetoothSenderPage();
}

class _BluetoothSenderPage extends State<BluetoothSenderPage> {
  List<int> peripheralMessage = [];

  @override
  void initState() {
    super.initState();

    // Hack. force async to be sync.
    () async {
      await BlePeripheral.initialize();

    //   await BlePeripheral.addService(
    //     BleService(
    //       uuid: serviceUuid,
    //       primary: true,
    //       characteristics: [
    //         BleCharacteristic(uuid: characteristicUuid, properties: [
    //           CharacteristicProperties.write.index,
    //         ], permissions: [
    //           AttributePermissions.writeable.index,
    //         ]),
    //       ],
    //     ),
    //     timeout: const Duration(seconds: 15),
    //   );

    //   BlePeripheral.setWriteRequestCallback(
    //     (deviceId, characteristicId, offset, value) {
    //       // TODO: Add a check to filter out that this only runs for our service characterisitic.

    //       peripheralMessage += value ?? [];

    //       if (mounted) {
    //         setState(() {});
    //       }
    //   });

		BlePeripheral.setReadRequestCallback((deviceId, characteristicId, offset, value) {
			return ReadRequestResult(value: utf8.encode(
				"""
				This is a long message to test the capabilitlies/ Oops... a misspelling.
				I just want to have a really long message to test what is possible with
				this read only architecture. This should go beyond what is normally expected
				to force the application to be compatible for what is expected. 

				At this point this is total gibberish that makes my head spin. But it's long,
				it's boring, and it's best of all... plain. It's the ramblings of a man who has
				lost it all to the terrible creature called: Bluetooth. 

				I don't recommend anybody to ever face this foe as it may take your sanity as it
				has taken mine. I will never let go of this hatred that is held deep for Bluetooth.\n
				"""
			));
		});
    }();
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
      children: [
        FloatingToggleButton(
          labelText: "Advertise",
          initialIcon: const Icon(Icons.public_off),
          initialColor: Colors.red,
          pressedColor: Colors.blue,
          pressedIcon: const Icon(Icons.public),
          onPressed: (pressed) async {
            if (await Permission.bluetoothAdvertise.isDenied) {
              final status = await Permission.bluetoothAdvertise.request();

              if (status.isDenied) {
                return;
              }
            }

            if (pressed) {
              await BlePeripheral.startAdvertising(services: [], localName: "GreenScoutSender");
            } else {
              await BlePeripheral.stopAdvertising();
            }
          },
        ),
        Text(utf8.decode(peripheralMessage)),
      ],
    );
  }
}
