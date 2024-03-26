import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

// Ensures we have a consistent service id to interface with.

const serviceUuid = "0000180F-0000-1000-8000-00805F9B34FB";
const characteristicUuid = "00002A19-0000-1000-8000-00805F9B34FB";

// Code taken from: https://pub.dev/packages/flutter_bluetooth_sharing/example
Future<bool> isBTPermissionGiven() async {
  if (Platform.isIOS) {
    if (!await Permission.bluetooth.isRestricted) {
      return true;
    } else {
      var response = await [Permission.bluetooth].request();
      return response[Permission.bluetooth]?.isGranted == true;
    }
  } else if (Platform.isAndroid) {
    var isAndroidS = (int.tryParse(
      (await DeviceInfoPlugin().androidInfo).version.release) ??
      0) >=
      11;

    if (isAndroidS) {
      if (await Permission.bluetoothScan.isGranted) {
        return true;
      } else {
        var response = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect
        ].request();
        return response[Permission.bluetoothScan]?.isGranted == true &&
          response[Permission.bluetoothConnect]?.isGranted == true;
      }
    } else {
      return true;
    }
  }

  return false;
}

bool isBTPermissionGivenSync() {
  bool result = false;

  // Hack.
  () async {
    result = await isBTPermissionGiven();
  }();

  return result;
}