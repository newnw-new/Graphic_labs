import 'package:flutter/material.dart';
import 'package:graphic/core/utils/Geomerty.dart';
import 'package:graphic/core/utils/matrix3.dart';
import 'package:graphic/core/widgets/coordinateGrid.dart';
import 'package:graphic/core/widgets/pointfield.dart';
import 'package:graphic/features/tasks/labFour/algos.dart';

class TaskFirstLabFour extends StatefulWidget {
  const TaskFirstLabFour({super.key});

  @override
  State<TaskFirstLabFour> createState() => _TaskFirstLabFourState();
}

class _TaskFirstLabFourState extends State<TaskFirstLabFour> {
  final List<DrawableFigure> figures = [];

  // Контроллеры для отрезка
  final VecEditingController _controllerA = VecEditingController(2);
  final VecEditingController _controllerB = VecEditingController(2);

  // Список контроллеров вершин многоугольника
  final List<VecEditingController> _polygonControllers = [];

  void _addVertex() {
    _polygonControllers.add(VecEditingController(2));
    setState(() {});
  }

  void _removeVertex(int index) {
    _polygonControllers.removeAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Область рисования
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
        // Панель ввода
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                const Text(
                    'Кирус-Бек',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, fontStyle: FontStyle.italic),
                  ),
                const SizedBox(height: 8,),
                  const Text(
                    'Многоугольник',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._buildPolygonInputs(),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _addVertex,
                    icon: const Icon(Icons.add),
                    label: const Text('Добавить вершину'),
                  ),
                  const Divider(height: 32),
                  const Text('Отрезок', style: TextStyle(fontWeight: FontWeight.bold)),
                  VecField(name: 'A', controller: _controllerA),
                  VecField(name: 'B', controller: _controllerB),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _calculate,
                    child: const Text('Расчёт'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildPolygonInputs() {
    List<Widget> widgets = [];
    for (int i = 0; i < _polygonControllers.length; i++) {
      widgets.add(
        Row(
          key: ValueKey(_polygonControllers[i]),
          children: [
            Expanded(
              child: VecField(
                name: 'V$i',
                controller: _polygonControllers[i],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeVertex(i),
            ),
          ],
        ),
      );
    }
    return widgets;
  }

  void _calculate() {
    List<Vec> polygon = [];
    for (var ctrl in _polygonControllers) {
      final vals = ctrl.values();
      final x = double.tryParse(vals[0])!;
      final y = double.tryParse(vals[1])!;
      polygon.add(Vec([x, y]));
    }

    final aVals = _controllerA.values();
    final bVals = _controllerB.values();

    final ax = double.tryParse(aVals[0])!;
    final ay = double.tryParse(aVals[1])!;
    final bx = double.tryParse(bVals[0])!;
    final by = double.tryParse(bVals[1])!;

    final P1 = Vec([ax, ay]);
    final P2 = Vec([bx, by]);

    setState(() {
      figures.clear();

      final polygonOffsets = polygon.map((v) => v.toOffset()).toList();
      figures.add(DrawablePath(
        contours: [polygonOffsets],
        transform: Matrix3.identity(),
        paint: Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      ));

      figures.add(DrawableSegment(
        A: Offset(ax, ay),
        B: Offset(bx, by),
        transform: Matrix3.identity(),
        paint: Paint()
          ..color = Colors.blue
          ..strokeWidth = 2,
      ));

      final result = cyrusBeckClip(P1, P2, polygon);

      final entryPoints = result[0]!;
      final exitPoints = result[1]!;
      final clippedSegment = result[2];

      // Точки входа и выхода (красные)
      if (entryPoints.isNotEmpty) {
        final allPoints = [...entryPoints];
        figures.add(DrawablePoints(
          points: allPoints.map((v) => v.toOffset()).toList(),
          transform: Matrix3.identity(),
          paint: Paint()
            ..color = Colors.green
            ..style = PaintingStyle.fill,
        ));
      }

      if (exitPoints.isNotEmpty) {
        final allPoints = [...exitPoints];
        figures.add(DrawablePoints(
          points: allPoints.map((v) => v.toOffset()).toList(),
          transform: Matrix3.identity(),
          paint: Paint()
            ..color = Colors.red
            ..style = PaintingStyle.fill,
        ));
      }

      // Отсечённый отрезок (жёлтый, толстый)
      if (clippedSegment != null) {
        figures.add(DrawableSegment(
          A: clippedSegment[0].toOffset(),
          B: clippedSegment[1].toOffset(),
          transform: Matrix3.identity(),
          paint: Paint()
            ..color = Colors.yellow
            ..strokeWidth = 4,
        ));
      }
    });
  }

  @override
  void dispose() {
    _polygonControllers.clear();
    super.dispose();
  }
}