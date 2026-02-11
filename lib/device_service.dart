import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

import 'app_constants.dart';

class DeviceService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static Future<void> collectAndSendDeviceData() async {
    try {
      final deviceData = await _collectDeviceData();
      await _sendDeviceDataToServer(deviceData);
      print('Device data sent successfully');
    } catch (e) {
      throw Exception('Failed to collect and send device data: $e');
    }
  }

  static Future<Map<String, dynamic>> _collectDeviceData() async {
    final data = <String, dynamic>{};

    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;

      data['manufacturer'] = androidInfo.manufacturer;
      data['model'] = androidInfo.model;
      data['brand'] = androidInfo.brand;
      data['device'] = androidInfo.device;
      data['product'] = androidInfo.product;
      data['fingerprint'] = androidInfo.fingerprint;
      data['android_version'] = androidInfo.version.release;
      data['sdk'] = androidInfo.version.sdkInt;
      data['device_id'] = androidInfo.id;

      data['hardware'] = androidInfo.hardware;
      data['board'] = androidInfo.board;
      data['bootloader'] = androidInfo.bootloader;
      data['display'] = androidInfo.display;
      data['host'] = androidInfo.host;
      data['tags'] = androidInfo.tags;
      data['type'] = androidInfo.type;

      data['is_physical_device'] = androidInfo.isPhysicalDevice;
      data['supported_abis'] = androidInfo.supportedAbis;
      data['supported_32bit_abis'] = androidInfo.supported32BitAbis;
      data['supported_64bit_abis'] = androidInfo.supported64BitAbis;

    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;

      data['name'] = iosInfo.name;
      data['model'] = iosInfo.model;
      data['system_name'] = iosInfo.systemName;
      data['system_version'] = iosInfo.systemVersion;
      data['device_id'] = iosInfo.identifierForVendor;
      data['is_physical_device'] = iosInfo.isPhysicalDevice;
      data['utsname_machine'] = iosInfo.utsname.machine;
      data['utsname_sysname'] = iosInfo.utsname.sysname;
      data['utsname_release'] = iosInfo.utsname.release;
      data['utsname_version'] = iosInfo.utsname.version;

    } else if (kIsWeb) {
      final webInfo = await _deviceInfo.webBrowserInfo;

      data['browser_name'] = webInfo.browserName.toString();
      data['app_name'] = webInfo.appName;
      data['app_version'] = webInfo.appVersion;
      data['user_agent'] = webInfo.userAgent;
      data['platform'] = webInfo.platform;
      data['vendor'] = webInfo.vendor;
      data['language'] = webInfo.language;
    }

    data['platform'] = Platform.operatingSystem;
    data['platform_version'] = Platform.operatingSystemVersion;
    data['locale'] = Platform.localeName;

    return data;
  }

  static Future<void> _sendDeviceDataToServer(Map<String, dynamic> data) async {
    data['timestamp'] = DateTime.now().millisecondsSinceEpoch;

    try {
      final secureClient = AppConstants.getSecureClient();
      final response = await secureClient.post(
        Uri.parse(AppConstants.deviceEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Device data sent successfully. Status: ${response.statusCode}');
      } else {
        print('Failed to send device data. Status: ${response.statusCode}');
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending device data: $e');
      rethrow;
    }
  }
}