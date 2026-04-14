import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:graphic/core/widgets/coordinateGrid.dart';
import 'package:graphic/core/utils/matrix3.dart';

class TaskSecondLabSecond extends StatefulWidget {
  const TaskSecondLabSecond({super.key});

  @override
  State<TaskSecondLabSecond> createState() => _TaskSecondLabSecondState();
}

class _TaskSecondLabSecondState extends State<TaskSecondLabSecond>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _time = 0;

  @override
  void initState() {
    super.initState();
    _ticker = Ticker((elapsed) {
      setState(() {
        _time = elapsed.inMilliseconds / 1000.0;
      });
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = [
      [
        Offset(-12, 0), // Тело
        Offset(-12, 1),
        Offset(0, 2),
        Offset(0, -2),
        Offset(-12, 0),
      ],
      [Offset(0, 2), Offset(3, 1), Offset(3, -1), Offset(0, -2)], //мотор
      [Offset(-3, 0), Offset(-11, -4), Offset(-7, 0)], //Боковое крыло
      [Offset(-12, 1), Offset(-12, 4), Offset(-10, 1)], //Заднее крыло
      [Offset(3, 0.5), Offset(4, 0), Offset(3, -0.5)], // Крепеж для лопастей
    ];
    final wings = [[Offset(3.5, 0.25), Offset(3.5, 5)], [Offset(3.5, -0.25), Offset(3.5, -5)]];

    final dx = -20 + (_time * 5) % 40;

    final translation = Matrix3.translation(dx, 0).scale(0.5, 0.5);
    final wingAnimation = translation.scale(1, sin(_time*15));

    return CoordinateGrid(
      figures: [
        DrawableFigure(
          contours: body,
          transform: translation,
          paint: Paint()
            ..color = Colors.black87
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
        ),
        DrawableFigure(
          contours: wings,
          transform: wingAnimation,
          paint: Paint()
            ..color = Colors.black87
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5,
        ),
      ],
      showAxes: false,
      showGrid: false,
      isPan: false,
      isZoom: false
    );
  }
}
