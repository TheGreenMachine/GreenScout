// Part of code stolen from: 
// https://github.com/boskokg/flutter_blue_plus/tree/master/example

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:green_scout/pages/navigation_layout.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:green_scout/utils/bluetooth_utils.dart';
import 'package:green_scout/utils/snackbar.dart';
import 'package:green_scout/widgets/floating_button.dart';
import 'package:green_scout/widgets/scan_result_tile.dart';

class BluetoothSenderPage extends StatefulWidget {
	const BluetoothSenderPage({super.key});

	@override
	State<BluetoothSenderPage> createState() => _BluetoothSenderPage();
}

class _BluetoothSenderPage extends State<BluetoothSenderPage> {

	// This code is borrowed from the flutter blue plus example.
	List<BluetoothDevice> _systemDevices = [];
	List<ScanResult> _scanResults = [];
	bool _isScanning = false;
	late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  	late StreamSubscription<bool> _isScanningSubscription;

	BluetoothDevice? currentDevice;

	@override
	void initState() {
		super.initState();

		_scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
			_scanResults = [];

			for (final result in results) {
				for (final service in result.device.servicesList) {
					if (service.uuid.str128 == serviceUuid.toLowerCase()) {
						break;
					}
				}

				// if (result.device.advName.isEmpty) {
				// 	break;
				// }

				_scanResults.add(result);
			}

			if (mounted) {
				setState(() {});
			}
		}, onError: (e) {
			Snackbar.show(ABC.b, prettyException("Scan Error:", e), success: false);
		});

		_isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
				_isScanning = state;
				if (mounted) {
					setState(() {});
				}
			}
		);
	}

	@override
	void deactivate() {
		_scanResultsSubscription.cancel();
		_isScanningSubscription.cancel();

		super.deactivate();
	}

	Future<void> onConnectPressed(BluetoothDevice device) async {
		try {
			if (currentDevice != null) { 
				await currentDevice!.disconnect().catchError((e) {
					Snackbar.show(ABC.c, prettyException("Disconnect Error: ", e), success: false);
				});
			}

			if (!device.isConnected) {
				await device.connect(mtu: null).catchError((e) {
					Snackbar.show(ABC.c, prettyException("Connect Error:", e), success: false);
				});

				currentDevice = device;
			} else {
				await device.disconnect().catchError((e) {
					Snackbar.show(ABC.c, prettyException("Disconnect Error: ", e), success: false);
				});

				currentDevice = null;
			}
		} finally {
			
		}
	}

	List<Widget> _buildSystemDeviceTiles(BuildContext context) {
		return _systemDevices
			.map(
				(d) => Text(d.advName),
			)
			.toList();
	}

	List<Widget> _buildScanResultTiles(BuildContext context) {
		return _scanResults
			.map(
				(r) => ScanResultTile(
					result: r,
					onTap: () async => await onConnectPressed(r.device),
				),
			)
		.toList();
	}

	Color hmm = Colors.yellow;

	Future<void> sendDataToDevice(String message) async {
		if (currentDevice == null) {
			final random = Random();
			hmm = Color.fromARGB(255, random.nextInt(255), random.nextInt(255), random.nextInt(255));
			setState(() {});
			return;
		}

		for (var service in currentDevice!.servicesList) {
      hmm = Colors.green;
      setState(() {});
			// if (service.uuid.str128 != serviceUuid.toLowerCase()) {
			// 	continue;
			// }

			for (var characteristic in service.characteristics) {
				// if (characteristic.uuid.str128 != characteristicUuid.toLowerCase()) {
				// 	continue;
				// }

				// if (!characteristic.properties.write) {
				// 	continue;
				// }
				
				try {
					hmm = Colors.red;
		setState(() {});


				// The '3' is for the amount of space the bluetooth
				// device takes up for sending the data.
				final maximumMessageSize = currentDevice!.mtuNow - 3;

				final packetCount = message.length ~/ maximumMessageSize;

				for (var i = 0; i < packetCount; i++) {
					await characteristic.write(
						utf8.encode(message)
							.sublist(
								i     * maximumMessageSize,
								(i+1) * maximumMessageSize,
							), 
						withoutResponse: characteristic.properties.writeWithoutResponse,
					);
				}

				if (message.length % maximumMessageSize != 0) {
					await characteristic.write(
						utf8.encode(message)
							.sublist(packetCount * maximumMessageSize), 
						withoutResponse: characteristic.properties.writeWithoutResponse,
					);
				}
				} finally { hmm = Colors.blue;
		setState(() {});
				 }
			}
		}

		setState(() {});
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
				FloatingButton(
					labelText: "Find Device",
					onPressed: () async {
						try {
							_systemDevices = await FlutterBluePlus.systemDevices;
						} catch (e) {
							Snackbar.show(ABC.b, prettyException("System Devices Error:", e), success: false);
						}

						await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));

						if (mounted) {
							setState(() {});
						}
					},
				),
				FloatingButton(
					labelText: "Write Example Data",
					onPressed: () async {
						await sendDataToDevice("This is a message that tests the capabilities of the device when sending a pretty long message.\nThe length of this message is mostly just to be padded and to obscure and be nonsensical. I believe this should all be sent without a single problem... Hopefully...");	
					},
					color: hmm,
				),
				..._buildSystemDeviceTiles(context),
				..._buildScanResultTiles(context),
			],
		);
	}
}