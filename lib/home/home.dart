import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:just_audio/just_audio.dart';

import 'objects/nyancat.dart';
import 'objects/star.dart';

const kSpaceColors = [
  Color.fromRGBO(10, 52, 97, 1),
  Color(0xff1c253c),
  Color(0xff1f3e5a),
  Color(0xff000007),
  Color(0xff00023f),
  Color(0xff000754),
];

class MyHomePage extends StatefulWidget {
  MyHomePage({
    super.key,
    required this.frames,
    required this.audioPlayer,
  }) : luckySeed = Random().nextInt(76) + 25;

  final List<ui.Image> frames;
  final AudioPlayer audioPlayer;

  final int luckySeed;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _counter = 0;
  int _rotation = 0;
  bool _direction = true;
  double _angle = 0;
  double _scale = 1;
  Color _fabColor = Colors.teal;
  final Color _bgColor = Color.fromRGBO(10, 52, 97, 1);
  final int _nyanSpeed = Random().nextInt(15000) + 5000;
  List<Offset> _translationOffset = [];
  final _starList = <Star>[];
  final _cat = <Widget>[];
  Timer? _timer;

  void setStars() {
    _starList.clear();
    _starList.addAll(List.generate(
      widget.luckySeed,
          (index) => Star(
        duration: Duration(seconds: Random().nextInt(3) + 1),
        offset: _translationOffset[index],
        angle: _angle,
        sparkSize: 2,
        margin: Random().nextDouble() * 10 + 4,
        oppositeOfNyan: _direction,
      ),
    ));
  }

  void setNyanAndTail() => _cat.add(
    NyanCat(
      frames: widget.frames,
      angle: _angle,
      tailCount: Random().nextInt(10) * 2 + 4,
      speed: _nyanSpeed,
      audioPlayer: widget.audioPlayer,
    ),
  );

  void _incrementCounter() => setState(() {
    _counter++;

    _fabColor = Color.fromRGBO(
      Random().nextInt(255),
      Random().nextInt(255),
      Random().nextInt(255),
      1,
    );

    setUpViewPortInstance();

    if (_cat.length > 20) _cat.removeRange(0, 10);

    setNyanAndTail();
  });

  void setAngle() => _angle = (DateTime.now().second % 2 == 0 ? -1 : 1) *
      (Random().nextInt(7) + 1) *
      pi /
      (Random().nextInt(270) + 10);

  void setScale() => _scale = 1 + Random().nextDouble() + Random().nextDouble();

  void setDirection() => _direction = Random().nextBool();

  void setOffsets() => _translationOffset = List.generate(
    widget.luckySeed,
        (idx) => Offset(Random().nextDouble(), Random().nextDouble()),
  );

  void setRotation() => _rotation = Random().nextInt(2);

  void setUpViewPortInstance() {
    setRotation();
    setScale();
    setAngle();
    setDirection();
    setOffsets();
    setStars();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _incrementCounter();
    });
  }

  @override
  void initState() {
    super.initState();
    setUpViewPortInstance();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: _nyanSpeed ~/ 3),
      tween: ColorTween(
        begin: _bgColor,
        end: kSpaceColors[Random().nextInt(kSpaceColors.length)],
      ),
      builder: (_, color, child) => Scaffold(
        backgroundColor: color,
        body: child,
      ),
      child: RotatedBox(
        quarterTurns: _rotation,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(_direction ? pi : 0)..scale(_scale),
          child: Stack(
            children: [
              ..._starList,
              ..._cat,
            ],
          ),
        ),
      ),
    );
  }
}