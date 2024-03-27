import 'dart:convert';

import 'package:ble_peripheral/ble_peripheral.dart';
import 'package:flutter/material.dart';
import 'package:green_scout/pages/navigation_layout.dart';
import 'package:green_scout/utils/bluetooth_utils.dart';
import 'package:green_scout/widgets/toggle_floating_button.dart';

class BluetoothReceiverPage extends StatefulWidget {
  const BluetoothReceiverPage({super.key});

  @override
  State<BluetoothReceiverPage> createState() => _BluetoothReceiverPage();
}

class _BluetoothReceiverPage extends State<BluetoothReceiverPage> {
  List<int> peripheralMessage = [];

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
            BleCharacteristic(uuid: characteristicUuid, properties: [
              CharacteristicProperties.write.index,
            ], permissions: [
              AttributePermissions.writeable.index,
            ]),
          ],
        ),
        timeout: const Duration(seconds: 15),
      );

      BlePeripheral.setWriteRequestCallback(
        (deviceId, characteristicId, offset, value) {
          // TODO: Add a check to filter out that this only runs for our service characterisitic.

          peripheralMessage += value ?? [];

          if (mounted) {
            setState(() {});
          }
      });
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
      children: [
        FloatingToggleButton(
          labelText: "Advertise",
          initialIcon: const Icon(Icons.public_off),
          initialColor: Colors.red,
          pressedColor: Colors.blue,
          pressedIcon: const Icon(Icons.public),
          onPressed: (pressed) async {
            if (pressed) {
              await BlePeripheral.startAdvertising(
                  services: [serviceUuid], localName: "GreenScoutReceiver");
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
