// Part of code stolen from: 
// https://github.com/boskokg/flutter_blue_plus/tree/master/example

import 'dart:async';

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

	@override
	void initState() {
		super.initState();

		_scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
			_scanResults = [];

			for (final result in results) {
				for (final uuid in result.advertisementData.serviceUuids) {
					// if (uuid.str128 == serviceUuid.toLowerCase()) {
					// 	break;
					// }

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

	void onConnectPressed(BluetoothDevice device) {

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
					onTap: () => onConnectPressed(r.device),
				),
			)
		.toList();
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

			body: ListView(
				children: [
					FloatingButton(
						labelText: "Connect",
						onPressed: () async {
							await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));

							if (mounted) {
								setState(() {});
							}
						},
					),
					..._buildSystemDeviceTiles(context),
					..._buildScanResultTiles(context),
				],
			),
		);
	}

	Widget buildBody(BuildContext context) {
		return ListView(
			children: [
				FloatingButton(
					labelText: "Connect",
					onPressed: () async {
						await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));

						if (mounted) {
							setState(() {});
						}
					},
				),
				..._buildSystemDeviceTiles(context),
				..._buildScanResultTiles(context),
			],
		);
	}
}