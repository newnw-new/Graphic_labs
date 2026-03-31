import 'package:flutter/material.dart';
import 'dart:math' as math;

class FlyingAirplane extends StatefulWidget {
  const FlyingAirplane({super.key});

  @override
  State<FlyingAirplane> createState() => _FlyingAirplaneState();
}

class _FlyingAirplaneState extends State<FlyingAirplane>
    with TickerProviderStateMixin {  // ← заменили SingleTickerProviderStateMixin
  late AnimationController _propellerController;
  late AnimationController _movementController;
  late Animation<double> _positionAnimation;

  @override
  void initState() {
    super.initState();

    // Анимация вращения пропеллера (бесконечная)
    _propellerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..repeat();

    // Анимация движения по горизонтали (туда-обратно)
    _movementController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    // Анимация смещения по X
    _positionAnimation = Tween<double>(begin: -200, end: 400)
        .animate(CurvedAnimation(parent: _movementController, curve: Curves.linear));
  }

  @override
  void dispose() {
    _propellerController.dispose();
    _movementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Летящий самолёт')),
      body: AnimatedBuilder(
        animation: Listenable.merge([_propellerController, _positionAnimation]),
        builder: (context, child) {
          return CustomPaint(
            painter: AirplanePainter(
              propellerAngle: _propellerController.value * 2 * math.pi,
              xOffset: _positionAnimation.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class AirplanePainter extends CustomPainter {
  final double propellerAngle;
  final double xOffset;

  AirplanePainter({required this.propellerAngle, required this.xOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final double centerY = size.height / 2;
    final double centerX = size.width / 2 + xOffset;

    canvas.save();
    canvas.translate(centerX, centerY);

    // Корпус самолёта
    final Paint bodyPaint = Paint()..color = Colors.blue;
    final Path body = Path();
    body.moveTo(-30, 0);
    body.lineTo(0, -10);
    body.lineTo(60, -8);
    body.lineTo(70, 0);
    body.lineTo(60, 8);
    body.lineTo(0, 10);
    body.close();
    canvas.drawPath(body, bodyPaint);

    // Крылья
    final Paint wingPaint = Paint()..color = Colors.blueGrey;
    canvas.drawRect(const Rect.fromLTWH(30, -15, 40, 6), wingPaint);
    canvas.drawRect(const Rect.fromLTWH(30, 9, 40, 6), wingPaint);

    // Хвост
    final Paint tailPaint = Paint()..color = Colors.blue;
    final Path tail1 = Path();
    tail1.moveTo(-20, -6);
    tail1.lineTo(-35, -12);
    tail1.lineTo(-20, -10);
    tail1.close();
    canvas.drawPath(tail1, tailPaint);

    final Path tail2 = Path();
    tail2.moveTo(-20, 6);
    tail2.lineTo(-35, 12);
    tail2.lineTo(-20, 10);
    tail2.close();
    canvas.drawPath(tail2, tailPaint);

    // Пропеллер
    canvas.save();
    canvas.translate(-30, 0);
    canvas.rotate(propellerAngle);
    final Paint propPaint = Paint()..color = Colors.brown..strokeWidth = 4;
    canvas.drawLine(const Offset(0, 0), const Offset(20, 0), propPaint);
    canvas.drawLine(const Offset(0, 0), const Offset(-20, 0), propPaint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, 20), propPaint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, -20), propPaint);
    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant AirplanePainter oldDelegate) {
    return oldDelegate.propellerAngle != propellerAngle ||
        oldDelegate.xOffset != xOffset;
  }
}