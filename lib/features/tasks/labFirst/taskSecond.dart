import 'package:flutter/material.dart';
import 'package:graphic/core/widgets/pointfield.dart';
import 'package:graphic/core/utils/Geomerty.dart';
import 'package:graphic/core/widgets/inputbox.dart';

class TaskSecond extends StatefulWidget {
  const TaskSecond({super.key});

  @override
  State<TaskSecond> createState() => _TaskSecondState();
}

class _TaskSecondState extends State<TaskSecond> {
  String? _answer = null;
  Color _answerColor = Colors.blue;
  final VecEditingController _controllerA = VecEditingController(2);
  final VecEditingController _controllerB = VecEditingController(2);
  final VecEditingController _controllerC = VecEditingController(2);

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
            'Задание 2. Вариант 2. Даны три точки А,В,С, лежащие на одной прямой. Определить расположение точки С относительно отрезка АВ (между точками А и В, вне отрезка за точкой А, вне отрезка за точкой В).',
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
                  child: Text('Делай дело два'),
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

        final potencialAnswer = _func2(
          _controllerA.values().map((c) => double.parse(c)).toList(),
          _controllerB.values().map((c) => double.parse(c)).toList(),
          _controllerC.values().map((c) => double.parse(c)).toList(),
        ) ;
        _answer = potencialAnswer != null ? potencialAnswer : 'Точка C лежит не на одной прямой с AB.';
        _answerColor = potencialAnswer != null? Colors.blue : Colors.redAccent;
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

String? _func2(
  List<double> coordinatesA,
  List<double> coordinatesB,
  List<double> coordinatesC,
) {
  final AB = Vec(coordinatesA) - Vec(coordinatesB);
  final AC = Vec(coordinatesA) - Vec(coordinatesC);

  double? scalarRes = scalarProduct(AB, AC);

  if (scalarRes == null ||
      !Line.withStartVecAndVec(
        startVec: Vec(coordinatesA),
        vec: AB,
      ).VecAtLine(Vec(coordinatesC)))
    return null;

  double result = scalarRes / AB.euclideanNorm2();

  if (result < 0)
    return 'Левее';
  else if (result <= 1)
    return 'На отрезке';
  else
    return 'Правее';
}
