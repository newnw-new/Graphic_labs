import 'package:flutter/material.dart';
import 'package:graphic/core/utils/matrix3.dart';
import 'package:graphic/core/widgets/coordinateGrid.dart';
import 'package:graphic/core/widgets/inputbox.dart';
import 'package:graphic/core/widgets/pointfield.dart';
import 'package:graphic/features/tasks/labThird/secondTask/brezn_round.dart';

class TaskSecondLabThird extends StatefulWidget {
  const TaskSecondLabThird({super.key});

  @override
  State<TaskSecondLabThird> createState() => _TaskSecondLabThirdState();
}

class _TaskSecondLabThirdState extends State<TaskSecondLabThird> {
  DrawableCircle? _circle = null;
  DrawablePoints? _points = null;
  final VecEditingController _controllerRadius = VecEditingController(1);
  final VecEditingController _controllerCenter = VecEditingController(2);

  @override
  Widget build(BuildContext context) {
    List<DrawableFigure> figures = [];
    if (_circle != null) figures.add(_circle!);
    if (_points != null) figures.add(_points!);

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CoordinateGrid(
                figures: figures,
                gridColor: Colors.grey.shade300,
                axesColor: Colors.red,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.all(16),
            child: InputBox(
              fields: [
                VecField(name: 'Радиус', controller: _controllerRadius),
                VecField(name: 'Центр', controller: _controllerCenter),
              ],
              button: ElevatedButton(
                onPressed: _calculate,
                child: Text('Расчет'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _calculate() {
    setState(() {
      _circle = DrawableCircle(center: Offset(double.tryParse(_controllerCenter.values().elementAt(0))!, double.tryParse(_controllerCenter.values().elementAt(1))!), radius: double.tryParse(_controllerRadius.values().elementAt(0))!, transform: Matrix3.identity(), paint: Paint()..color = Colors.red..style = PaintingStyle.stroke..strokeWidth = 1);
      _points = DrawablePoints(points: bresenhamRound(int.tryParse(_controllerCenter.values().elementAt(0))!, int.tryParse(_controllerCenter.values().elementAt(1))!, int.tryParse(_controllerRadius.values().elementAt(0))!).map((e) => Offset(e.x.toDouble(), e.y.toDouble())).toList(), transform: Matrix3.identity(), paint: Paint()..color = Colors.blue);
    });
  }
}
