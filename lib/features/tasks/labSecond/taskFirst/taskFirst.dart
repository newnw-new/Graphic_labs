import 'dart:math';

import 'package:flutter/material.dart';
import 'package:graphic/core/widgets/coordinateGrid.dart';
import 'package:graphic/core/widgets/helpButtons.dart';
import 'package:graphic/features/tasks/labSecond/matrix3.dart';
import 'package:graphic/features/tasks/labSecond/taskFirst/transformEditor.dart';

class TaskFirstLabSecond extends StatefulWidget {
  const TaskFirstLabSecond({super.key});

  @override
  State<TaskFirstLabSecond> createState() => _TaskFirstLabSecondState();
}

class _TaskFirstLabSecondState extends State<TaskFirstLabSecond> {
  late DrawableFigure _Figure;

  List<Matrix3> _history = [Matrix3.identity()];

  int _historyIndex = 0;

  @override
  void initState() {
    super.initState();

    //Создаём звезду – копируем логику из Star.generateStarPoints
    final starPoints = _generateStarPoints(
      outerRadius: 2,
      innerRadius: 1,
      points: 5,
    );
    _Figure = DrawableFigure(
      contours: [
        [
          Offset(-0.9510565162951536, -0.3090169943749473),
          Offset(-1.1755705045849465, -1.6180339887498947),
          Offset(1.9021130325903073, 0.6180339887498943),
          Offset(0.5877852522924734, 0.8090169943749472),
          Offset(1.2246467991473532e-16, 2),
          Offset(-0.587785252292473, 0.8090169943749475),
          Offset(-1.902113032590307, 0.618033988749895),
          Offset(1.1755705045849458, -1.6180339887498951),
          Offset(0.9510565162951535, -0.3090169943749477),
        ],
        [Offset(-1.8369701987210297e-16, -1), Offset(-0.587785252292473, 0.8090169943749475)],
        [Offset(-1.8369701987210297e-16, -1), Offset(1.2246467991473532e-16, 2)],
        [Offset(-1.8369701987210297e-16, -1), Offset(0.587785252292473, 0.8090169943749475)],
      ],
      transform: Matrix3.identity(), // небольшое смещение для красоты
      paint: Paint()
        ..color = Colors.orange
        ..style = PaintingStyle.fill,
      closed: true,
    );
  }

  List<Offset> _generateStarPoints({
    required double outerRadius,
    required double innerRadius,
    required int points,
  }) {
    final list = <Offset>[];
    double angle = pi / 2;
    final step = 2 * pi / points;
    for (int i = 0; i < points; i++) {
      list.add(Offset(outerRadius * cos(angle), outerRadius * sin(angle)));
      list.add(
        Offset(
          innerRadius * cos(angle + step / 2),
          innerRadius * sin(angle + step / 2),
        ),
      );
      angle += step;
    }
    return list;
  }

  void _onApplyTransformations(DrawableFigure transformed) {
    setState(() {
      _Figure = transformed;
      _history.length = _historyIndex+1;
      _history.add(transformed.transform);
      _historyIndex+=1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: HelpButtons(
                onClear: _historyIndex  == 0? null:  () {setState(() {
                  _history.length = 1;
                  _historyIndex = 0;
                  _Figure = DrawableFigure(contours: _Figure.contours, transform: _history[0], paint: _Figure.paint);
                });},
                onBack: _historyIndex == 0? null: () {setState(() {
                  _historyIndex-=1;
                  _Figure = DrawableFigure(contours: _Figure.contours, transform: _history[_historyIndex], paint: _Figure.paint);
                });},
                onForward: _historyIndex == _history.length-1 ? null: () {setState(() {
                  _historyIndex+=1;
                  _Figure = DrawableFigure(contours: _Figure.contours, transform: _history[_historyIndex], paint: _Figure.paint);
                });},
                child: CoordinateGrid(
                  figures: [_Figure],
                  gridColor: Colors.grey.shade300,
                  axesColor: Colors.red,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 300,
          child: TransformEditor(
            Figure: _Figure,
            onApply: _onApplyTransformations,
          ),
        ),
      ],
    );
  }
}
