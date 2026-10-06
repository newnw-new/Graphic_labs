import 'package:flutter/material.dart';
import 'package:graphic/core/utils/Geomerty.dart';
import 'package:graphic/core/utils/matrix3.dart';
import 'package:graphic/core/widgets/coordinateGrid.dart';
import 'package:graphic/core/widgets/pointfield.dart';

class TaskFirstLabSix extends StatefulWidget {
  const TaskFirstLabSix({super.key});

  @override
  State<TaskFirstLabSix> createState() => _TaskFirstLabSixState();
}

class _TaskFirstLabSixState extends State<TaskFirstLabSix> {
  final List<DrawableFigure> _figures = [];
  final List<VecEditingController> _pointControllers = [];
  final List<Point> _points = [];
  final List<Point> _hull = [];

  void _addVertex() {
    _pointControllers.add(VecEditingController(2));
    setState(() {});
  }

  void _removeVertex(int index) {
    _pointControllers.removeAt(index);
    setState(() {});
  }

  void _updateFigures({List<DrawableFigure>? addFigures = null}) {
    _figures.clear();

    if (_hull.isNotEmpty) {
      _figures.add(
        DrawablePath.withPoints(
          points: _hull.map((e) => Offset(e.x, e.y)).toList(),
          transform: Matrix3.identity(),
          paint: Paint()
            ..color = Colors.blue
            ..strokeWidth = 4
            ..style = PaintingStyle.stroke,
        ),
      );
    }

    if (_points.isNotEmpty) {
      _figures.add(
        DrawablePoints(
          points: _points.map((e) => Offset(e.x, e.y)).toList(),
          transform: Matrix3.identity(),
          paint: Paint()
            ..color = Colors.black
            ..strokeWidth = 6,
        ),
      );
    }

    if (addFigures != null && addFigures.isNotEmpty) {
      for (var f in addFigures) {
        _figures.add(f);
      }
    }
  }

  Future<void> _calculate() async {
    _points.clear();
    for (var ctrl in _pointControllers) {
      final vals = ctrl.values();
      final x = double.tryParse(vals[0]);
      final y = double.tryParse(vals[1]);
      if (x == null || y == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Введите координаты всех точек'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      _points.add(Point(x, y));
    }

    _hull.clear();

    await completeJarvisAlgo(_points);

    setState(() {
      _updateFigures();
    });
  }

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
                figures: _figures,
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Точки',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  ..._buildPolygonInputs(),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _addVertex,
                    icon: const Icon(Icons.add),
                    label: const Text('Добавить точку'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _calculate,
                    child: const Text('Расчёт'),
                  ),
                  const Divider(height: 32),
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
    for (int i = 0; i < _pointControllers.length; i++) {
      widgets.add(
        Row(
          key: ValueKey(_pointControllers[i]),
          children: [
            Expanded(
              child: VecField(
                name: 'P${i + 1}',
                controller: _pointControllers[i],
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

  @override
  void dispose() {
    if (_pointControllers.isNotEmpty) {
      _pointControllers.clear();
    }
    super.dispose();
  }

  Future<void> completeJarvisAlgo(List<Point> points) async {
    final n = points.length;
    if (n <= 3) {
      _hull.addAll(points);
      return;
    }

    Point start = points[0];
    for (final p in points) {
      if (p.y < start.y || (p.y == start.y && p.x < start.x)) {
        start = p;
      }
    }

    Point current = start;
    while (_hull.isEmpty || current != _hull[0]) {
      _hull.add(current);
      setState(() {
        _updateFigures();
      });
      await Future.delayed(Duration(seconds: 1));
      current = await stepJarvisAlgo(points, _hull);
    }
    _hull.add(start);
  }

  Future<Point> stepJarvisAlgo(List<Point> points, List<Point> currentHull) async {
    Point? next;
    final Point current = currentHull[currentHull.length - 1];
    for (final p in points) {
      if (p == current) continue;
      if (next == null) {
        next = p;
        continue;
      }
      
      final drawNext = DrawableSegment(
        A: Offset(current.x, current.y),
        B: Offset(next.x, next.y),
        transform: Matrix3.identity(),
        paint: Paint()
          ..color = Colors.red
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke,
      );
      final drawP = DrawableSegment(
        A: Offset(current.x, current.y),
        B: Offset(p.x, p.y),
        transform: Matrix3.identity(),
        paint: Paint()
          ..color = Colors.green
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke,
      );
      setState(() {
        _updateFigures(addFigures: [drawNext, drawP]);
      });

      await Future.delayed(Duration(seconds: 1));

      final cr = cross(current, next, p);
      if (cr < 0) {
        next = p;
        final drawNext = DrawableSegment(
          A: Offset(current.x, current.y),
          B: Offset(next.x, next.y),
          transform: Matrix3.identity(),
          paint: Paint()
            ..color = Colors.red
            ..strokeWidth = 4
            ..style = PaintingStyle.stroke,
        );
        setState(() {
          _updateFigures(addFigures: [drawNext]);
        });
        await Future.delayed(Duration(seconds: 1));
      } else if (cr.abs() < 1e-6) {
        if (dist(current, p) > dist(current, next)) {
          next = p;

          final drawNext = DrawableSegment(
            A: Offset(current.x, current.y),
            B: Offset(next.x, next.y),
            transform: Matrix3.identity(),
            paint: Paint()
              ..color = Colors.red
              ..strokeWidth = 4
              ..style = PaintingStyle.stroke,
          );
          setState(() {
            _updateFigures(addFigures: [drawNext]);
          });
          await Future.delayed(Duration(seconds: 1));
        }
      }
    }

    return next!;
  }
}

num cross(Point o, Point a, Point b) {
  return (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x);
}

num dist(Point a, Point b) {
  final dx = a.x - b.x;
  final dy = a.y - b.y;
  return dx * dx + dy * dy;
}
