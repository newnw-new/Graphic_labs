import 'package:flutter/material.dart';
import 'package:graphic/core/utils/matrix3.dart';
import 'package:graphic/core/widgets/coordinateGrid.dart';
import 'package:graphic/core/widgets/inputbox.dart';
import 'package:graphic/core/widgets/pointfield.dart';
import 'package:graphic/features/tasks/labThird/firstTask/brezn_line.dart';

class TaskFirstLabThird extends StatefulWidget {
  const TaskFirstLabThird({super.key});

  @override
  State<TaskFirstLabThird> createState() => _TaskFirstLabThirdState();
}

class _TaskFirstLabThirdState extends State<TaskFirstLabThird> {
  List<DrawableFigure> _points = [];
  final VecEditingController _controllerA = VecEditingController(2);
  final VecEditingController _controllerB = VecEditingController(2);

  @override
  Widget build(BuildContext context) {
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
                figures: _points,
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
                VecField(name: 'A', controller: _controllerA),
                VecField(name: 'B', controller: _controllerB),
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
      _points =
          bresenham(
                int.tryParse(_controllerA.values().elementAt(0))!,
                int.tryParse(_controllerA.values().elementAt(1))!,
                int.tryParse(_controllerB.values().elementAt(0))!,
                int.tryParse(_controllerB.values().elementAt(1))!,
              )
              .map(
                (e) => DrawablePath(
                  contours: [
                    [Offset(e.x.toDouble(), e.y.toDouble())],
                  ],
                  transform: Matrix3.identity(),
                  paint: Paint()..color = Colors.blue,
                ),
              )
              .toList();
        _points.add(
                DrawablePath(
                  contours: [
                    [
                      Offset(
                        double.tryParse(_controllerA.values().elementAt(0))!,
                        double.tryParse(_controllerA.values().elementAt(1))!,
                      ),
                      Offset(
                        double.tryParse(_controllerB.values().elementAt(0))!,
                        double.tryParse(_controllerB.values().elementAt(1))!,
                      ),
                    ],
                  ],
                  transform: Matrix3.identity(),
                  paint: Paint()
                    ..color = Colors.red
                    ..strokeWidth = 1
                    ..style = PaintingStyle.stroke,
                ),
              );
    });
  }
}
