import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';

import 'app_constants.dart';

@pragma('vm:entry-point')
class LocationService {
  static final LocationService instance = LocationService._internal();
  factory LocationService() => instance;
  LocationService._internal();

  final service = FlutterBackgroundService();

  @pragma('vm:entry-point')
  Future<void> initialize() async {
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'location_service_channel',
        initialNotificationTitle: '',
        initialNotificationContent: '',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  Future<void> startLocationTracking() async {
    await initialize();
    service.startService();
  }

  @pragma('vm:entry-point')
  Future<void> stopLocationTracking() async {
    service.invoke("stop");
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    if (service is AndroidServiceInstance) {
      service.setAsForegroundService();
    }

    service.on('stop').listen((event) {
      service.stopSelf();
    });

    final deviceInfo = DeviceInfoPlugin();
    String deviceId = 'unknown';

    if (Platform.isAndroid) {
      deviceId = (await deviceInfo.androidInfo).id;
    }

    final locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      intervalDuration: const Duration(seconds: 30),
      distanceFilter: 0,
    );

    Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
          (position) async {
        await _sendLocationToServer(
          position.latitude,
          position.longitude,
          deviceId,
        );
      },
      onError: (e) {
        debugPrint("Location stream error: $e");
      },
    );
  }

  @pragma('vm:entry-point')
  static Future<void> _sendLocationToServer(
      double latitude,
      double longitude,
      String deviceId,
      ) async {
    try {
      final data = {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'device_id': deviceId,
      };

      final secureClient = AppConstants.getSecureClient();
      final response = await secureClient.post(
        Uri.parse(AppConstants.locationEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print('Background location sent successfully');
      } else {
        print('Failed to send background location: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending background location: $e');
    }
  }
}