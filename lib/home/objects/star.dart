import 'dart:math';
import 'package:flutter/material.dart';
import '../painters/spark_painter.dart';

class Star extends StatefulWidget {
  const Star({
    super.key,
    required this.duration,
    required this.offset,
    required this.angle,
    this.margin = 5,
    this.sparkSize = 2,
    this.oppositeOfNyan = false,
  });

  final Offset offset;
  final Duration duration;
  final double angle;
  final double margin;
  final double sparkSize;
  final bool oppositeOfNyan;

  @override
  _StarState createState() => _StarState();
}

class _StarState extends State<Star> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final IntTween _nyanTween;

  @override
  void initState() {
    super.initState();

    _anim = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: Random().nextDouble(),
    )
      ..repeat()
      ..addListener(() {
        setState(() {});
      });

    _nyanTween = IntTween(begin: 0, end: 5);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SparkPainter(
        relativeOff: _anim.value,
        sparkSize: widget.sparkSize,
        margin: widget.margin,
        phase: _nyanTween.animate(_anim).value,
        opposite: widget.oppositeOfNyan,
        translateBy: widget.offset,
        angleInRadians: widget.angle,
      ),
      child: Container(),
    );
  }
}