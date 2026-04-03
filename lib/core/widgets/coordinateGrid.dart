import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:graphic/core/utils/Geomerty.dart';
import 'package:graphic/features/tasks/labSecond/matrix3.dart'; // ваш файл с Matrix, Matrix3

class DrawableFigure {
  final List<List<Offset>> contours;
  final Matrix3 transform;
  final Paint paint;
  final bool closed;

  DrawableFigure({
    required this.contours,
    required this.transform,
    required this.paint,
    this.closed = false,
  }) : assert(
         contours.isNotEmpty && contours.every((c) => c.isNotEmpty),
         'Контуры не могут быть пустыми',
       );

  // Удобный конструктор для фигур из одного контура
  factory DrawableFigure.withPoints({
    required List<Offset> points,
    required Matrix3 transform,
    required Paint paint,
    bool closed = false,
  }) {
    return DrawableFigure(
      contours: [points],
      transform: transform,
      paint: paint,
      closed: closed,
    );
  }
}

class CoordinateGrid extends StatefulWidget {
  final List<DrawableFigure> figures;
  final Color gridColor;
  final double gridStrokeWidth;
  final Color axesColor;
  final double axesStrokeWidth;

  const CoordinateGrid({
    super.key,
    required this.figures,
    this.gridColor = Colors.grey,
    this.gridStrokeWidth = 1.0,
    this.axesColor = Colors.black,
    this.axesStrokeWidth = 2.0,
  });

  @override
  State<CoordinateGrid> createState() => _CoordinateGridState();
}

class _CoordinateGridState extends State<CoordinateGrid> {
  Offset _pan = Offset.zero;
  double _zoom = 1.0;

  // Для панорамирования мышью (через GestureDetector)
  Offset? _panStart;
  Offset? _dragStartPan;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return MouseRegion(
          cursor: SystemMouseCursors.grab, // рука при наведении
          child: Listener(
            onPointerSignal: (event) {
              if (event is PointerScrollEvent) {
                _onScroll(event, size);
              }
            },
            child: GestureDetector(
              onPanStart: (details) {
                setState(() {
                  _dragStartPan = _pan;
                  _panStart = details.localPosition;
                });
              },
              onPanUpdate: (details) {
                if (_panStart != null && _dragStartPan != null) {
                  final delta = details.localPosition - _panStart!;
                  setState(() {
                    _pan = _dragStartPan! + delta / (15 * _zoom);
                  });
                }
              },
              onPanEnd: (details) {
                setState(() {
                  _panStart = null;
                  _dragStartPan = null;
                });
              },
              child: CustomPaint(
                painter: _GridPainter(
                  figures: widget.figures,
                  pan: _pan,
                  zoom: _zoom,
                  gridColor: widget.gridColor,
                  gridStrokeWidth: widget.gridStrokeWidth,
                  axesColor: widget.axesColor,
                  axesStrokeWidth: widget.axesStrokeWidth,
                ),
                size: size,
              ),
            ),
          ),
        );
      },
    );
  }

  void _onScroll(PointerScrollEvent event, Size size) {
    final delta = event.scrollDelta.dy;
    final scaleFactor = 1 - delta / 500; // чувствительность
    final newZoom = (_zoom * scaleFactor).clamp(0.2, 10.0);

    print('${_toWorldCoordinates(screenPoint: event.localPosition, size: size, pan: _pan, zoom: _zoom).dx} ${_toWorldCoordinates(screenPoint: event.localPosition, size: size, pan: _pan, zoom: _zoom).dy}');

    setState(() {
      _zoom = newZoom;
    });
  }
}

class _GridPainter extends CustomPainter {
  final List<DrawableFigure> figures;
  final Offset pan;
  final double zoom;
  final Color gridColor;
  final double gridStrokeWidth;
  final Color axesColor;
  final double axesStrokeWidth;

  _GridPainter({
    required this.figures,
    required this.pan,
    required this.zoom,
    required this.gridColor,
    required this.gridStrokeWidth,
    required this.axesColor,
    required this.axesStrokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGridTransformed(canvas, size);
    _drawAxes(canvas, size);
    _drawFigures(canvas, size);
  }

  void _drawGridTransformed(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = gridStrokeWidth
      ..style = PaintingStyle.stroke;

    final worldXY = _worldCornerPoints(size);

    for (
      double x = worldXY.minX.ceil().toDouble();
      x <= worldXY.maxX.floor().toDouble();
      x += 1
    ) {
      final p1 = _toScreenCoordinates(
        screenPoint: Offset(x, worldXY.minY),
        size: size,
        pan: pan,
        zoom: zoom,
      );
      final p2 = _toScreenCoordinates(
        screenPoint: Offset(x, worldXY.maxY),
        size: size,
        pan: pan,
        zoom: zoom,
      );
      canvas.drawLine(p1, p2, paint);
    }
    for (
      double y = worldXY.minY.ceil().toDouble();
      y <= worldXY.maxY.floor().toDouble();
      y += 1
    ) {
      final p1 = _toScreenCoordinates(
        screenPoint: Offset(worldXY.minX, y),
        size: size,
        pan: pan,
        zoom: zoom,
      );
      final p2 = _toScreenCoordinates(
        screenPoint: Offset(worldXY.maxX, y),
        size: size,
        pan: pan,
        zoom: zoom,
      );
      canvas.drawLine(p1, p2, paint);
    }
  }

  void _drawAxes(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = axesColor
      ..strokeWidth = axesStrokeWidth
      ..style = PaintingStyle.stroke;

    final worldXY = _worldCornerPoints(size);

    if (worldXY.minX <= 0 && 0 <= worldXY.maxX) {
      canvas.drawLine(
        _toScreenCoordinates(
          screenPoint: Offset(0, worldXY.minY),
          size: size,
          pan: pan,
          zoom: zoom,
        ),
        _toScreenCoordinates(
          screenPoint: Offset(0, worldXY.maxY),
          size: size,
          pan: pan,
          zoom: zoom,
        ),
        paint,
      );
    }

    if (worldXY.minY <= 0 && 0 <= worldXY.maxY) {
      canvas.drawLine(
        _toScreenCoordinates(
          screenPoint: Offset(worldXY.minX, 0),
          size: size,
          pan: pan,
          zoom: zoom,
        ),
        _toScreenCoordinates(
          screenPoint: Offset(worldXY.maxX, 0),
          size: size,
          pan: pan,
          zoom: zoom,
        ),
        paint,
      );
    }
  }

  void _drawFigures(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    //final worldXY = _worldCornerPoints(size);

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    for(int i = 0; i < figures.length; ++i){
    Path figurePath = Path();
      for(int j = 0; j < figures[i].contours.length; ++j){
        final screenStartPoint = _toScreenCoordinates(screenPoint: figures[i].transform.transform(figures[i].contours[j][0]), size: size, pan: pan, zoom: zoom);
        figurePath.moveTo(screenStartPoint.dx, screenStartPoint.dy);
        for(int k = 1; k < figures[i].contours[j].length; ++k){
          final screenPoint = _toScreenCoordinates(screenPoint: figures[i].transform.transform(figures[i].contours[j][k]), size: size, pan: pan, zoom: zoom);
          figurePath.lineTo(screenPoint.dx, screenPoint.dy);
        }
      }
      figurePath.close();
      canvas.drawPath(figurePath, paint);
    }
    canvas.restore();
  }

  _XY _worldCornerPoints(Size size) {
    final topLeft = _toWorldCoordinates(
      screenPoint: Offset.zero,
      size: size,
      pan: pan,
      zoom: zoom,
    );
    final bottomRight = _toWorldCoordinates(
      screenPoint: Offset(size.width, size.height),
      size: size,
      pan: pan,
      zoom: zoom,
    );

    final minX = min(topLeft.dx, bottomRight.dx);
    final maxX = max(topLeft.dx, bottomRight.dx);
    final minY = min(topLeft.dy, bottomRight.dy);
    final maxY = max(topLeft.dy, bottomRight.dy);

    return _XY(minX: minX, maxX: maxX, minY: minY, maxY: maxY);
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.figures != figures ||
        oldDelegate.pan != pan ||
        oldDelegate.zoom != zoom ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.gridStrokeWidth != gridStrokeWidth ||
        oldDelegate.axesColor != axesColor ||
        oldDelegate.axesStrokeWidth != axesStrokeWidth;
  }
}

Offset _toWorldCoordinates({
  required Offset screenPoint,
  required Size size,
  required Offset pan,
  required double zoom,
}) {
  final left = -10 / zoom - pan.dx;
  final right = 10 / zoom - pan.dx;
  final top = 10 / zoom + pan.dy;
  final bottom = -10 / zoom + pan.dy;
  final wx = left + (screenPoint.dx / size.width) * (right - left);
  final wy =
      bottom + ((size.height - screenPoint.dy) / size.height) * (top - bottom);
  return Offset(wx, wy);
}

Offset _toScreenCoordinates({
  required Offset screenPoint,
  required Size size,
  required Offset pan,
  required double zoom,
}) {
  final left = -10 / zoom - pan.dx;
  final right = 10 / zoom - pan.dx;
  final top = 10 / zoom + pan.dy;
  final bottom = -10 / zoom + pan.dy;
  final sx = ((screenPoint.dx - left) / (right - left)) * size.width;
  final sy =
      -((screenPoint.dy - bottom) * size.height / (top - bottom) - size.height);
  return Offset(sx, sy);
}

class _XY {
  final minX;
  final minY;
  final maxX;
  final maxY;

  _XY({this.maxX, this.maxY, this.minX, this.minY});
}
