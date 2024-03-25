import 'dart:async';

import 'package:flutter/material.dart';
import 'package:green_scout/pages/navigation_layout.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:green_scout/utils/snackbar.dart';

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
					// break;
				// }
				}
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