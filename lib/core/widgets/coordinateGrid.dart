import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:graphic/core/utils/matrix3.dart';
import 'package:graphic/core/utils/Geomerty.dart';

abstract class DrawableFigure {
  final Matrix3 transform;
  final Paint paint;

  DrawableFigure({required this.transform, required this.paint});

  void draw({
    required Canvas canvas,
    required Size size,
    required Offset pan,
    required double zoom,
  });
}

class DrawablePath extends DrawableFigure {
  final List<List<Offset>> contours;

  DrawablePath({
    required this.contours,
    required super.transform,
    required super.paint,
  }) : assert(
         contours.isNotEmpty && contours.every((c) => c.isNotEmpty),
         'Контуры не могут быть пустыми',
       );

  factory DrawablePath.withPoints({
    required List<Offset> points,
    required Matrix3 transform,
    required Paint paint,
  }) {
    return DrawablePath(contours: [points], transform: transform, paint: paint);
  }

  @override
  void draw({
    required Canvas canvas,
    required Size size,
    required Offset pan,
    required double zoom,
  }) {
    Path figurePath = Path();
    for (int j = 0; j < contours.length; ++j) {
      final screenStartPoint = _toScreenCoordinates(
        worldPoint: transform
            .multiplyOnVec(Vec.fromOffset(contours[j][0]))
            .toOffset(),
        size: size,
        pan: pan,
        zoom: zoom,
      );
      contours[j].length == 1
          ? canvas.drawCircle(
              Offset(screenStartPoint.dx, screenStartPoint.dy),
              4,
              paint,
            )
          : figurePath.moveTo(screenStartPoint.dx, screenStartPoint.dy);
      for (int k = 1; k < contours[j].length; ++k) {
        final screenPoint = _toScreenCoordinates(
          worldPoint: transform
              .multiplyOnVec(Vec.fromOffset(contours[j][k]))
              .toOffset(),
          size: size,
          pan: pan,
          zoom: zoom,
        );
        figurePath.lineTo(screenPoint.dx, screenPoint.dy);
      }
    }
    figurePath.close();
    canvas.drawPath(figurePath, paint);
  }
}

class DrawableCircle extends DrawableFigure {
  final Offset center;
  final double radius;

  DrawableCircle({
    required this.center,
    required this.radius,
    required super.transform,
    required super.paint,
  });

  @override
  void draw({
    required Canvas canvas,
    required Size size,
    required Offset pan,
    required double zoom,
  }) {
    const int segments = 128;
    final path = Path();

    for (int i = 0; i <= segments; i++) {
      final angle = 2 * pi * i / segments;

      final localPoint =
          center + Offset(radius * cos(angle), radius * sin(angle));

      final worldPoint = transform
          .multiplyOnVec(Vec.fromOffset(localPoint))
          .toOffset();

      final screenPoint = _toScreenCoordinates(
        worldPoint: worldPoint,
        size: size,
        pan: pan,
        zoom: zoom,
      );

      if (i == 0) {
        path.moveTo(screenPoint.dx, screenPoint.dy);
      } else {
        path.lineTo(screenPoint.dx, screenPoint.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }
}

class DrawablePoints extends DrawableFigure {
  final List<Offset> points; // локальные координаты точек

  DrawablePoints({
    required this.points,
    required super.transform,
    required super.paint,
  });

  @override
  void draw({
    required Canvas canvas,
    required Size size,
    required Offset pan,
    required double zoom,
  }) {
    for (var localPoint in points) {
      final world = transform
          .multiplyOnVec(Vec.fromOffset(localPoint))
          .toOffset();
      final screen = _toScreenCoordinates(
        worldPoint: world,
        size: size,
        pan: pan,
        zoom: zoom,
      );

      canvas.drawCircle(screen, 4, paint);
    }
  }
}

class DrawableRectangle extends DrawableFigure {
  final Offset topLeftPoint;
  final Offset bottomRightPoint;

  DrawableRectangle({
    required this.topLeftPoint,
    required this.bottomRightPoint,
    required super.transform,
    required super.paint,
  });

  @override
  void draw({
    required Canvas canvas,
    required Size size,
    required Offset pan,
    required double zoom,
  }) {
    final worldTopLeftPoint = transform.multiplyOnVec(Vec.fromOffset(topLeftPoint)).toOffset();
    final worldBottomRightPoint = transform.multiplyOnVec(Vec.fromOffset(bottomRightPoint)).toOffset();
    final screenTopLeftPoint = _toScreenCoordinates(worldPoint: worldTopLeftPoint, size: size, pan: pan, zoom: zoom);
    final screenBottomRightPoint = _toScreenCoordinates(worldPoint: worldBottomRightPoint, size: size, pan: pan, zoom: zoom);
    canvas.drawRect(Rect.fromLTRB(screenTopLeftPoint.dx, screenTopLeftPoint.dy, screenBottomRightPoint.dx, screenBottomRightPoint.dy), paint);
  }
}

class DrawableSegment extends DrawableFigure{
  final Offset A;
  final Offset B;

  DrawableSegment({required this.A, required this.B, required super.transform, required super.paint});

  @override
  void draw({required Canvas canvas, required Size size, required Offset pan, required double zoom}) {
    final worldA = transform.multiplyOnVec(Vec.fromOffset(A)).toOffset();
    final worldB = transform.multiplyOnVec(Vec.fromOffset(B)).toOffset();
    final screenA = _toScreenCoordinates(worldPoint: worldA, size: size, pan: pan, zoom: zoom);
    final screenB = _toScreenCoordinates(worldPoint: worldB, size: size, pan: pan, zoom: zoom);
    canvas.drawLine(screenA, screenB, paint);
  }

}


class CoordinateGrid extends StatefulWidget {
  final List<DrawableFigure> figures;
  final Color gridColor;
  final double gridStrokeWidth;
  final Color axesColor;
  final double axesStrokeWidth;
  final bool showGrid;
  final bool showAxes;
  final bool isPan;
  final bool isZoom;

  const CoordinateGrid({
    super.key,
    required this.figures,
    this.gridColor = Colors.grey,
    this.gridStrokeWidth = 1.0,
    this.axesColor = Colors.black,
    this.axesStrokeWidth = 2.0,
    this.showGrid = true,
    this.showAxes = true,
    this.isPan = true,
    this.isZoom = true,
  });

  @override
  State<CoordinateGrid> createState() => _CoordinateGridState();
}

class _CoordinateGridState extends State<CoordinateGrid> {
  Offset _pan = Offset.zero;
  double _zoom = 1.0;

  Offset? _panStart;
  Offset? _dragStartPan;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return MouseRegion(
          cursor: widget.isPan
              ? SystemMouseCursors.grab
              : SystemMouseCursors.basic,
          child: Listener(
            onPointerSignal: widget.isZoom
                ? (event) {
                    if (event is PointerScrollEvent) {
                      _onScroll(event, size);
                    }
                  }
                : null,
            child: GestureDetector(
              onPanStart: widget.isPan
                  ? (details) {
                      setState(() {
                        _dragStartPan = _pan;
                        _panStart = details.localPosition;
                      });
                    }
                  : null,
              onPanUpdate: widget.isPan
                  ? (details) {
                      if (_panStart != null && _dragStartPan != null) {
                        final delta = details.localPosition - _panStart!;
                        setState(() {
                          _pan = _dragStartPan! + delta / (15 * _zoom);
                        });
                      }
                    }
                  : null,
              onPanEnd: widget.isPan
                  ? (details) {
                      setState(() {
                        _panStart = null;
                        _dragStartPan = null;
                      });
                    }
                  : null,
              child: CustomPaint(
                painter: _GridPainter(
                  figures: widget.figures,
                  pan: _pan,
                  zoom: _zoom,
                  gridColor: widget.gridColor,
                  gridStrokeWidth: widget.gridStrokeWidth,
                  axesColor: widget.axesColor,
                  axesStrokeWidth: widget.axesStrokeWidth,
                  drawGrid: widget.showGrid,
                  drawAxes: widget.showAxes,
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

    //print('${_toWorldCoordinates(screenPoint: event.localPosition, size: size, pan: _pan, zoom: _zoom).dx} ${_toWorldCoordinates(screenPoint: event.localPosition, size: size, pan: _pan, zoom: _zoom).dy}');

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
  final bool drawGrid;
  final bool drawAxes;

  _GridPainter({
    required this.figures,
    required this.pan,
    required this.zoom,
    required this.gridColor,
    required this.gridStrokeWidth,
    required this.axesColor,
    required this.axesStrokeWidth,
    required this.drawGrid,
    required this.drawAxes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (drawGrid) _drawGridTransformed(canvas, size);
    if (drawAxes) _drawAxes(canvas, size);
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
        worldPoint: Offset(x, worldXY.minY),
        size: size,
        pan: pan,
        zoom: zoom,
      );
      final p2 = _toScreenCoordinates(
        worldPoint: Offset(x, worldXY.maxY),
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
        worldPoint: Offset(worldXY.minX, y),
        size: size,
        pan: pan,
        zoom: zoom,
      );
      final p2 = _toScreenCoordinates(
        worldPoint: Offset(worldXY.maxX, y),
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
          worldPoint: Offset(0, worldXY.minY),
          size: size,
          pan: pan,
          zoom: zoom,
        ),
        _toScreenCoordinates(
          worldPoint: Offset(0, worldXY.maxY),
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
          worldPoint: Offset(worldXY.minX, 0),
          size: size,
          pan: pan,
          zoom: zoom,
        ),
        _toScreenCoordinates(
          worldPoint: Offset(worldXY.maxX, 0),
          size: size,
          pan: pan,
          zoom: zoom,
        ),
        paint,
      );
    }
  }

  void _drawFigures(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    for (var figure in figures) {
      figure.draw(canvas: canvas, size: size, pan: pan, zoom: zoom);
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
  required Offset worldPoint,
  required Size size,
  required Offset pan,
  required double zoom,
}) {
  final left = -10 / zoom - pan.dx;
  final right = 10 / zoom - pan.dx;
  final top = 10 / zoom + pan.dy;
  final bottom = -10 / zoom + pan.dy;
  final sx = ((worldPoint.dx - left) / (right - left)) * size.width;
  final sy =
      -((worldPoint.dy - bottom) * size.height / (top - bottom) - size.height);
  return Offset(sx, sy);
}

class _XY {
  final minX;
  final minY;
  final maxX;
  final maxY;

  _XY({this.maxX, this.maxY, this.minX, this.minY});
}
