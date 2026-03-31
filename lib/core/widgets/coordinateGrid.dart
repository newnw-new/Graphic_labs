import 'dart:math';
import 'package:flutter/material.dart';
import 'package:graphic/core/utils/Geomerty.dart';
import 'package:graphic/features/tasks/labSecond/matrix3.dart'; // ваш файл с Matrix, Matrix3

class DrawableFigure {
  final List<Offset> points; // точки в локальной системе координат
  final Matrix3 transform; // преобразование относительно мирового начала
  final Paint paint; // стиль отрисовки
  final bool closed; // замыкать ли путь (соединять последнюю точку с первой)

  DrawableFigure({
    required this.points,
    required this.transform,
    required this.paint,
    this.closed = true,
  });
}

/// Виджет координатной сетки с поддержкой масштабирования и панорамирования.
class CoordinateGrid extends StatefulWidget {
  final List<DrawableFigure> figures; // список фигур для отображения
  final double gridSpacing; // шаг сетки в мировых единицах
  final Color gridColor; // цвет сетки
  final double gridStrokeWidth; // толщина линий сетки
  final Color axesColor; // цвет осей
  final double axesStrokeWidth; // толщина осей

  const CoordinateGrid({
    Key? key,
    required this.figures,
    this.gridSpacing = 50.0,
    this.gridColor = Colors.grey,
    this.gridStrokeWidth = 1.0,
    this.axesColor = Colors.black,
    this.axesStrokeWidth = 2.0,
  }) : super(key: key);

  @override
  State<CoordinateGrid> createState() => _CoordinateGridState();
}

class _CoordinateGridState extends State<CoordinateGrid> {
  // Трансформация сетки: смещение (pan) и масштаб (zoom)
  Offset _pan = Offset.zero;
  double _zoom = 1.0;

  // Для обработки жестов
  Offset? _previousFocalPoint;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details) {
        _previousFocalPoint = details.focalPoint;
      },
      onScaleUpdate: (details) {
        setState(() {
          // Обновляем масштаб
          _zoom *= details.scale;
          // Обновляем смещение (панорамирование)
          if (_previousFocalPoint != null) {
            final delta = details.focalPoint - _previousFocalPoint!;
            _pan +=
                delta / _zoom; // корректируем смещение относительно масштаба
          }
          _previousFocalPoint = details.focalPoint;
        });
      },
      onScaleEnd: (details) {
        _previousFocalPoint = null;
      },
      child: CustomPaint(
        painter: _GridPainter(
          figures: widget.figures,
          pan: _pan,
          zoom: _zoom,
          gridSpacing: widget.gridSpacing,
          gridColor: widget.gridColor,
          gridStrokeWidth: widget.gridStrokeWidth,
          axesColor: widget.axesColor,
          axesStrokeWidth: widget.axesStrokeWidth,
        ),
        size: Size.infinite, // занимает всё доступное пространство
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final List<DrawableFigure> figures;
  final Offset pan;
  final double zoom;
  final double gridSpacing;
  final Color gridColor;
  final double gridStrokeWidth;
  final Color axesColor;
  final double axesStrokeWidth;

  _GridPainter({
    required this.figures,
    required this.pan,
    required this.zoom,
    required this.gridSpacing,
    required this.gridColor,
    required this.gridStrokeWidth,
    required this.axesColor,
    required this.axesStrokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Матрица для преобразования мировых координат в экранные
    final transform = Matrix4.identity()
      ..translate(size.width / 2, size.height / 2) // центр экрана
      ..scale(zoom, zoom) // масштаб
      ..translate(pan.dx, pan.dy); // панорамирование

    canvas.transform(transform.storage);

    // Рисуем сетку
    _drawGrid(canvas, size);

    // Рисуем фигуры
    for (final figure in figures) {
      _drawFigure(canvas, figure);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = gridStrokeWidth
      ..style = PaintingStyle.stroke;

    // Определяем границы видимой области в мировых координатах
    final topLeft = _toWorld(Offset.zero, size);
    final bottomRight = _toWorld(Offset(size.width, size.height), size);

    final startX = (topLeft.dx / gridSpacing).floor() * gridSpacing;
    final startY = (topLeft.dy / gridSpacing).floor() * gridSpacing;
    final endX = (bottomRight.dx / gridSpacing).ceil() * gridSpacing;
    final endY = (bottomRight.dy / gridSpacing).ceil() * gridSpacing;

    // Вертикальные линии
    for (double x = startX; x <= endX; x += gridSpacing) {
      canvas.drawLine(Offset(x, startY), Offset(x, endY), paint);
    }

    // Горизонтальные линии
    for (double y = startY; y <= endY; y += gridSpacing) {
      canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
    }

    // Рисуем оси
    final axisPaint = Paint()
      ..color = axesColor
      ..strokeWidth = axesStrokeWidth;
    canvas.drawLine(Offset(0, startY), Offset(0, endY), axisPaint); // ось Y
    canvas.drawLine(Offset(startX, 0), Offset(endX, 0), axisPaint); // ось X
  }

  void _drawFigure(Canvas canvas, DrawableFigure figure) {
    if (figure.points.isEmpty) return;

    final path = Path();
    final matrix = figure.transform;

    // Применяем преобразование к первой точке
    final first = matrix.transform(figure.points.first);
    path.moveTo(first.dx, first.dy);

    // Применяем преобразование к остальным точкам
    for (int i = 1; i < figure.points.length; i++) {
      final point = matrix.transform(figure.points[i]);
      path.lineTo(point.dx, point.dy);
    }

    // Замыкаем, если нужно
    if (figure.closed && figure.points.isNotEmpty) {
      path.close();
    }

    canvas.drawPath(path, figure.paint);
  }

  Offset _toWorld(Offset screenPoint, Size size) {
    // Обратное преобразование: экранные координаты -> мировые
    final center = Offset(size.width / 2, size.height / 2);
    final world = (screenPoint - center) / zoom - pan;
    return world;
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.figures != figures ||
        oldDelegate.pan != pan ||
        oldDelegate.zoom != zoom ||
        oldDelegate.gridSpacing != gridSpacing ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.gridStrokeWidth != gridStrokeWidth ||
        oldDelegate.axesColor != axesColor ||
        oldDelegate.axesStrokeWidth != axesStrokeWidth;
  }
}
