import 'dart:math';

import 'package:flutter/material.dart';
import 'package:graphic/core/widgets/coordinateGrid.dart';
import 'package:graphic/core/widgets/helpButtons.dart';
import 'package:graphic/core/utils/matrix3.dart';
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

    _Figure = DrawableFigure(
      contours: [
        [
          Offset(0.0, 2.0),
          Offset(-0.6, 0.8),
          Offset(0.0, -1.0),
          Offset(0.0, 2.0)
        ],
        [Offset(0.0, 2.0), Offset(0.6, 0.8), Offset(0.0, -1)],
        [Offset(0.6, 0.8), Offset(1.9, 0.6), Offset(0.0, -1.0), Offset(0.6, 0.8)],
        [Offset(-0.6, 0.8), Offset(-1.9, 0.6), Offset(0.0, -1.0), Offset(-0.6, 0.8)],
        [Offset(0.0, -1.0), Offset(1.2, -1.6), Offset(1.0, -0.18)],
        [Offset(0.0, -1.0), Offset(-1.2, -1.6), Offset(-1.0, -0.18)]
      ],
      transform: Matrix3.identity(), // небольшое смещение для красоты
      paint: Paint()
        ..color = Colors.orange
        ..style = PaintingStyle.stroke,
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
