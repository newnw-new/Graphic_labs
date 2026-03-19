import 'package:flutter/material.dart';
import 'package:graphic/core/widgets/pointfield.dart';
import 'package:graphic/core/utils/Geomerty.dart';
import 'package:graphic/core/widgets/inputbox.dart';

class TaskThird extends StatefulWidget {
  const TaskThird({super.key});

  @override
  State<TaskThird> createState() => _TaskThirdState();
}

class _TaskThirdState extends State<TaskThird> {
  String? _answer = null;
  Color _answerColor = Colors.blue;
  final VecEditingController _controllerA = VecEditingController(3);
  final VecEditingController _controllerB = VecEditingController(3);
  final VecEditingController _controllerC = VecEditingController(3);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 8,
            top: 20,
            bottom: 20,
          ),
          child: Text(
            'Задание 3. Вариант 2. Треугольник задан координатами своих вершин. Определить вид треугольника (остроугольный, тупоугольный или прямоугольный)',
            maxLines: 5,
          ),
        ),

        Row(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.all(20),
                width: 500,
                height: 250,
                child: Image.asset('assets/images/soon.jpg', fit: BoxFit.fill),
              ),
            ),
            Expanded(
              child: InputBox(
                fields: [
                  VecField(name: 'A', controller: _controllerA),
                  VecField(name: 'B', controller: _controllerB),
                  VecField(name: 'C', controller: _controllerC),
                ],
                button: ElevatedButton(
                  onPressed: _calculate,
                  child: Text('Делай дело три'),
                ),
              ),
            ),
          ],
        ),
        if (_answer != null)
          Text('Результат: $_answer', style: TextStyle(color: _answerColor)),
      ],
    );
  }

  void _calculate() {
    setState(() {
      if (_controllerA.values().any((c) => c == '') ||
          _controllerB.values().any(
            (c) => (c == '') || _controllerC.values().any((c) => (c == '')),
          )) {
        _answer = 'Нужно заполнить все поля';
        _answerColor = Colors.redAccent;
      } else {
        _answer = _getTriangleType(
          _controllerA.values().map((c) => double.parse(c)).toList(),
          _controllerB.values().map((c) => double.parse(c)).toList(),
          _controllerC.values().map((c) => double.parse(c)).toList(),
        );
        _answerColor = Colors.blue;
      }
    });
  }

  @override
  void dispose() {
    _controllerA.dispose();
    _controllerB.dispose();
    _controllerC.dispose();
    super.dispose();
  }
}

String _getTriangleType(
  List<double> coordinatesA,
  List<double> coordinatesB,
  List<double> coordinatesC,
) {
  final AB = Vec(coordinatesA) - Vec(coordinatesB);
  final AC = Vec(coordinatesA) - Vec(coordinatesC);
  final BC = Vec(coordinatesB) - Vec(coordinatesC);

  double A = scalarProduct(AB, AC)!;
  double B = scalarProduct(AB, BC)!;
  double C = scalarProduct(AC, BC)!;

  if (A.abs() < 1e-6 || B.abs() < 1e-6 || C.abs() < 1e-6)
    return 'Прямоугольный';
  else if (A > 0 && B > 0 && C > 0)
    return 'Остроугольный';
  else
    return 'Тупоугольный';
}
