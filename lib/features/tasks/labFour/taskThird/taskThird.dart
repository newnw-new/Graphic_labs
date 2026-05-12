import 'package:flutter/material.dart';
import 'package:graphic/core/utils/matrix3.dart';
import 'package:graphic/core/widgets/coordinateGrid.dart';
import 'package:graphic/core/widgets/inputbox.dart';
import 'package:graphic/core/widgets/pointfield.dart';
import 'package:graphic/features/tasks/labFour/algos.dart';

class TaskThirdLabFour extends StatefulWidget {
  const TaskThirdLabFour({super.key});

  @override
  State<TaskThirdLabFour> createState() => _TaskThirdLabFourState();
}

class _TaskThirdLabFourState extends State<TaskThirdLabFour> {
  final List<DrawableFigure> figures = [];
  final VecEditingController _controllerTL = VecEditingController(2);
  final VecEditingController _controllerBR = VecEditingController(2);
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
            child: Column(
                children: [
                const Text(
                    'Метод средней точки',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, fontStyle: FontStyle.italic),
                  ),
                const SizedBox(height: 8,),
                const Text(
                    'Прямоугольник',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                VecField(name: 'Верхний левый угол', controller: _controllerTL),
                VecField(name: 'Нижний правый угол', controller: _controllerBR),
                const Divider(height: 16,),
                const Text(
                    'Прямая',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                VecField(name: 'A', controller: _controllerA),
                VecField(name: 'B', controller: _controllerB),
                ElevatedButton(
                onPressed: _calculate,
                child: Text('Расчет'),)
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _calculate() {
    setState(() {
    figures.clear();
    final TLx = double.tryParse(_controllerTL.values().elementAt(0))!;
    final TLy = double.tryParse(_controllerTL.values().elementAt(1))!;
    final BRx = double.tryParse(_controllerBR.values().elementAt(0))!;
    final BRy = double.tryParse(_controllerBR.values().elementAt(1))!;
    figures.add(DrawableRectangle(
      topLeftPoint: Offset(TLx, TLy),
      bottomRightPoint: Offset(BRx, BRy),
      transform: Matrix3.identity(),
      paint: Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    ));
    final Ax = double.tryParse(_controllerA.values().elementAt(0))!;
    final Ay = double.tryParse(_controllerA.values().elementAt(1))!;
    final Bx = double.tryParse(_controllerB.values().elementAt(0))!;
    final By = double.tryParse(_controllerB.values().elementAt(1))!;
    figures.add(DrawableSegment(
      A: Offset(Ax, Ay),
      B: Offset(Bx, By),
      transform: Matrix3.identity(),
      paint: Paint()
        ..color = Colors.blue
        ..strokeWidth = 4,
    ));
    List<List<double>> outputLines = midpointClip(Ax, Ay, Bx, By, TLx, BRx, BRy, TLy);
    for(List<double> segment in outputLines){
      figures.add(DrawableSegment(
        A: Offset(segment[0], segment[1]),
        B: Offset(segment[2], segment[3]),
        transform: Matrix3.identity(),
        paint: Paint()
          ..color = Colors.yellow
          ..strokeWidth = 4,
      ));
    }
    });
  }
}
