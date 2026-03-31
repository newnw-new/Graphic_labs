import 'package:flutter/material.dart';
import 'dart:math';

import 'package:graphic/core/widgets/coordinateGrid.dart';
import 'package:graphic/features/tasks/labSecond/matrix3.dart';

class Star extends StatelessWidget  {
  
  final Color borderColor;
  final double borderWidth;
  final int points;          // количество лучей
  final double innerRadiusFactor; // отношение внутреннего радиуса к внешнему (0..1)

  const Star({
    Key? key,
    this.borderColor = Colors.black,
    this.borderWidth = 2.0,
    this.points = 5,
    this.innerRadiusFactor = 0.4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final starPoints = generateStarPoints(50, 20, 5);
final starFigure = DrawableFigure(
  points: starPoints,
  transform: Matrix3.identity().translate(100, 0),
  paint: Paint()..color = Colors.orange..style = PaintingStyle.fill,
  closed: true,
);
  
    return 
    SizedBox(
      height: 100,
      width:  100,
      child: CoordinateGrid(
        figures: [starFigure],
        gridSpacing: 50,
        gridColor: Colors.grey.shade300,
        axesColor: Colors.red,)
    );
  }

  List<Offset> generateStarPoints(double outerRadius, double innerRadius, int points) {
  List<Offset> list = [];
  double angle = -pi / 2; // начальный угол (верхняя точка)
  final step = 2 * pi / points;
  for (int i = 0; i < points; i++) {
    list.add(Offset(outerRadius * cos(angle), outerRadius * sin(angle)));
    list.add(Offset(innerRadius * cos(angle + step / 2), innerRadius * sin(angle + step / 2)));
    angle += step;
  }
  return list;
}
}

class _StarPainter extends CustomPainter{
  final Color borderColor;
  final double borderWidth;
  final int points;
  final double innerRadiusFactor;

  _StarPainter({
    required this.borderColor,
    required this.borderWidth,
    required this.points,
    required this.innerRadiusFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = min(size.width, size.height) / 2;
    final innerRadius = outerRadius * innerRadiusFactor;

    final path = Path();
    double angle = -pi / 2; // начальный угол (верхняя точка)
    final step = 2 * pi / points;

    // Первая внешняя точка
    Offset start = Offset(
      center.dx + outerRadius * cos(angle),
      center.dy + outerRadius * sin(angle),
    );
    path.moveTo(start.dx, start.dy);

    for (int i = 0; i < points; i++) {
      // Внутренняя точка
      double innerAngle = angle + step / 2;
      Offset inner = Offset(
        center.dx + innerRadius * cos(innerAngle),
        center.dy + innerRadius * sin(innerAngle),
      );
      path.lineTo(inner.dx, inner.dy);

      // Следующая внешняя точка
      angle += step;
      Offset outer = Offset(
        center.dx + outerRadius * cos(angle),
        center.dy + outerRadius * sin(angle),
      );
      path.lineTo(outer.dx, outer.dy);
    }
    path.close();

    final lineStart = Offset(size.width/2 - size.width/4, size.height/2);
    final lineEnd = Offset(size.width/2 + size.width/4, size.height/2);

    canvas.drawLine(lineStart, lineEnd, Paint()..color = Colors.cyan..strokeWidth = 2);
    canvas.drawPath(path, Paint()..color = borderColor..style = PaintingStyle.stroke..strokeWidth = borderWidth);
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.points != points ||
        oldDelegate.innerRadiusFactor != innerRadiusFactor;
  }
}