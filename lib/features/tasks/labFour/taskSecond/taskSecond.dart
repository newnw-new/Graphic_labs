import 'package:flutter/material.dart';
import 'package:graphic/core/utils/matrix3.dart';
import 'package:graphic/core/widgets/coordinateGrid.dart';
import 'package:graphic/core/widgets/inputbox.dart';
import 'package:graphic/core/widgets/pointfield.dart';
import 'package:graphic/features/tasks/labFour/algos.dart';

class TaskSecondLabFour extends StatefulWidget {
  const TaskSecondLabFour({super.key});

  @override
  State<TaskSecondLabFour> createState() => _TaskSecondLabFourState();
}

class _TaskSecondLabFourState extends State<TaskSecondLabFour> {
  DrawableRectangle? rect = null;
  DrawableSegment? inputLine = null;
  DrawableSegment? outputLine = null;
  final VecEditingController _controllerTL = VecEditingController(2);
  final VecEditingController _controllerBR = VecEditingController(2);
  final VecEditingController _controllerA = VecEditingController(2);
  final VecEditingController _controllerB = VecEditingController(2);

  @override
  Widget build(BuildContext context) {
    List<DrawableFigure> figures = [];
    if (rect != null) figures.add(rect!);
    if (inputLine != null) figures.add(inputLine!);
    if (outputLine != null) figures.add(outputLine!);

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
                VecField(name: 'Верхний левый угол', controller: _controllerTL),
                VecField(name: 'Нижний правый угол', controller: _controllerBR),
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
    final TLx = double.tryParse(_controllerTL.values().elementAt(0))!;
    final TLy = double.tryParse(_controllerTL.values().elementAt(1))!;
    final BRx = double.tryParse(_controllerBR.values().elementAt(0))!;
    final BRy = double.tryParse(_controllerBR.values().elementAt(1))!;
    rect = DrawableRectangle(
      topLeftPoint: Offset(TLx, TLy),
      bottomRightPoint: Offset(BRx, BRy),
      transform: Matrix3.identity(),
      paint: Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    final Ax = double.tryParse(_controllerA.values().elementAt(0))!;
    final Ay = double.tryParse(_controllerA.values().elementAt(1))!;
    final Bx = double.tryParse(_controllerB.values().elementAt(0))!;
    final By = double.tryParse(_controllerB.values().elementAt(1))!;
    inputLine = DrawableSegment(
      A: Offset(Ax, Ay),
      B: Offset(Bx, By),
      transform: Matrix3.identity(),
      paint: Paint()
        ..color = Colors.blue
        ..strokeWidth = 4,
    );
    List<double>? outputCoords = SutherlandCohen(
      Ax,
      Ay,
      Bx,
      By,
      TLx,
      BRx,
      BRy,
      TLy,
    );
    if (outputCoords != null) {
      outputLine = DrawableSegment(
        A: Offset(outputCoords[0], outputCoords[1]),
        B: Offset(outputCoords[2], outputCoords[3]),
        transform: Matrix3.identity(),
        paint: Paint()
          ..color = Colors.yellow
          ..strokeWidth = 4,
      );
    } else outputLine = null;
    });
  }
}
