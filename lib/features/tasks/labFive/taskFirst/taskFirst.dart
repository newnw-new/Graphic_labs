import 'package:flutter/material.dart';
import 'package:graphic/core/utils/Geomerty.dart';
import 'package:graphic/core/utils/matrix3.dart';
import 'package:graphic/core/widgets/coordinateGrid.dart';
import 'package:graphic/core/widgets/pointfield.dart';
import 'dart:math';

class _Edge {
  double yMax;
  double xCurrent;
  double dx;

  _Edge(this.yMax, this.xCurrent, this.dx);
}

class TaskFirstLabFive extends StatefulWidget {
  const TaskFirstLabFive({super.key});

  @override
  State<TaskFirstLabFive> createState() => _TaskFirstLabFiveState();
}

class _TaskFirstLabFiveState extends State<TaskFirstLabFive> {
  final List<DrawableFigure> figures = [];
  final List<VecEditingController> _polygonControllers = [];

  // Состояние AET
  final List<_Edge> _activeEdges = [];
  final Map<int, List<_Edge>> _yList = {};
  int? _currentY;
  int? _minY;
  int? _maxY;
  int? _minX;
  int? _maxX;
  final List<Rect> _filledRects = [];
  List<Vec> _polygon = [];

  void _addVertex() {
    _polygonControllers.add(VecEditingController(2));
    setState(() {});
  }

  void _removeVertex(int index) {
    _polygonControllers.removeAt(index);
    setState(() {});
  }

  void _buildyList(List<Vec> vertices) {
    _yList.clear();
    double minY = double.infinity;
    double maxY = -double.infinity;
    double minX = double.infinity;
    double maxX = -double.infinity;

    for (int i = 0; i < vertices.length; i++) {
      final p1 = vertices[i];
      final p2 = vertices[(i + 1) % vertices.length];
      final x1 = p1.coordinates[0];
      final y1 = p1.coordinates[1];
      final x2 = p2.coordinates[0];
      final y2 = p2.coordinates[1];

      minY = min(minY, min(y1, y2));
      maxY = max(maxY, max(y1, y2));
      minX = min(minX, min(x1, x2));
      maxX = max(maxX, max(x1, x2));

      if ((y1 - y2).abs() < 1e-6) continue;

      double yMin, yMax, xAtYMin, dx;
      if (y1 < y2) {
        yMin = y1;
        yMax = y2;
        xAtYMin = x1;
        dx = (x2 - x1) / (y2 - y1);
      } else {
        yMin = y2;
        yMax = y1;
        xAtYMin = x2;
        dx = (x1 - x2) / (y1 - y2);
      }


      int yStart = yMin.ceil();
      _yList
          .putIfAbsent(yStart, () => [])
          .add(_Edge(yMax, xAtYMin, dx));
    }

    _minY = minY.ceil();
    _maxY = maxY.floor();
    _minX = minX.ceil() - 2;
    _maxX = maxX.floor() + 2;
  }

  void _stepFill() {
    if (_currentY == null) return;
    if (_currentY! > _maxY!) return;

    if (_yList.containsKey(_currentY!)) {
      _activeEdges.addAll(_yList[_currentY!]!);
    }

    _activeEdges.removeWhere((e) => e.yMax <= _currentY!);

    _activeEdges.sort((a, b) => a.xCurrent.compareTo(b.xCurrent));

    for (int i = 0; i < _activeEdges.length - 1; i += 2) {
      final ixCurrent = min(
        _activeEdges[i + 1].xCurrent,
        _activeEdges[i].xCurrent,
      );
      final iNextxCurrent = max(
        _activeEdges[i + 1].xCurrent,
        _activeEdges[i].xCurrent,
      );
      double xLeft =
           (ixCurrent - ixCurrent.floor()).abs() <
              (ixCurrent - ixCurrent.ceil()).abs()
           ? ixCurrent.floorToDouble()
           : ixCurrent.ceilToDouble();
      // double xRight =
      //     ((iNextxCurrent - iNextxCurrent.floor()).abs() <
      //         (iNextxCurrent - iNextxCurrent.ceil()).abs())
      //     ? iNextxCurrent.floorToDouble()
      //     : iNextxCurrent.ceilToDouble();
      //double xLeft = ixCurrent.floorToDouble();
      double xRight = iNextxCurrent.ceilToDouble();
      _filledRects.add(
        Rect.fromLTRB(xLeft, _currentY!.toDouble(), xRight, _currentY! + 1.0),
      );
    }

    for (var edge in _activeEdges) {
      edge.xCurrent += edge.dx;
    }

    _currentY = _currentY! + 1;
  }

  Future<void> _completeFill() async {
    while (_currentY! < _maxY!) {
      _stepFill();
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        _updateFigures();
      });
    }
  }

  void _updateFigures() {
    figures.clear();

    if (_polygon.isNotEmpty) {
      final polygonOffsets = _polygon.map((v) => v.toOffset()).toList();
      figures.add(
        DrawablePath(
          contours: [polygonOffsets],
          transform: Matrix3.identity(),
          paint: Paint()
            ..color = Colors.blue
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        ),
      );
    }

    if (_filledRects.isNotEmpty) {
      for (var rect in _filledRects) {
        figures.add(
          DrawableRectangle(
            topLeftPoint: rect.topLeft,
            bottomRightPoint: rect.bottomRight,
            transform: Matrix3.identity(),
            paint: Paint()
              ..color = Colors.yellow.shade200.withAlpha(125)
              ..style = PaintingStyle.fill,
          ),
        );
      }
    }

    if (_currentY != null) {
      figures.add(
        DrawableSegment(
          A: Offset(_minX!.toDouble(), _currentY!.toDouble()),
          B: Offset(_maxX!.toDouble(), _currentY!.toDouble()),
          transform: Matrix3.identity(),
          paint: Paint()
            ..color = Colors.red
            ..strokeWidth = 4,
        ),
      );
    }
  }

  Future<void> _calculate() async {
    List<Vec> polygon = [];
    for (var ctrl in _polygonControllers) {
      final vals = ctrl.values();
      final x = double.tryParse(vals[0]);
      final y = double.tryParse(vals[1]);
      if (x == null || y == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Введите координаты всех вершин'),
          backgroundColor: Colors.red,),
        );
        return;
      }
      polygon.add(Vec([x, y]));
    }
    if (polygon.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Многоугольник должен иметь хотя бы 3 вершины'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _polygon = polygon;
    _buildyList(polygon);
    _activeEdges.clear();
    _currentY = _minY;
    _filledRects.clear();

    setState(() {
      _updateFigures();
    });

    await _completeFill();
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
                figures: figures,
                gridColor: Colors.grey.shade300,
                axesColor: Colors.red,
              ),
            ),
          ),
        ),
        // Панель управления
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Многоугольник',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  ..._buildPolygonInputs(),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _addVertex,
                    icon: const Icon(Icons.add),
                    label: const Text('Добавить вершину'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _calculate,
                    child: const Text('Расчёт'),
                  ),
                  const Divider(height: 32),
                  // Кнопки управления AET
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
              child: VecField(name: 'V$i', controller: _polygonControllers[i]),
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
    if (_polygonControllers.isNotEmpty) {
      _polygonControllers.clear();
    }
    super.dispose();
  }
}
