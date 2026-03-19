import 'package:flutter/material.dart';
import 'package:graphic/core/utils/Geomerty.dart';
import 'package:graphic/core/widgets/pointfield.dart';
import 'package:graphic/core/widgets/inputbox.dart';

class TaskFour extends StatefulWidget {
  const TaskFour({super.key});

  @override
  State<TaskFour> createState() => _TaskFourState();
}

class _TaskFourState extends State<TaskFour> {
  String? _answer = null;
  Color _answerColor = Colors.blue;
  final VecEditingController _controllerA = VecEditingController(3);
  final VecEditingController _controllerB = VecEditingController(3);
  final VecEditingController _controllerC = VecEditingController(3);
  final VecEditingController _controllerD = VecEditingController(3);

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 8, top: 20, bottom: 20),
            child: Text('Задание 4. Вариант 2. Даны точки А, В, С, D своими координатами, найти уравнение плоскости проходящей через точку D и параллельную плоскости АВС.',
            maxLines: 5,),
          ),

          Row(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: EdgeInsets.all(20),
                  width: 500,
                  height: 250,
                  child: Image.asset('assets/images/soon.jpg',
                        fit: BoxFit.fill),
                ),
              ),
              Expanded(
                child: InputBox(fields: [
                  VecField(name: 'A', controller: _controllerA),
                  VecField(name: 'B', controller: _controllerB),
                  VecField(name: 'C', controller: _controllerC),
                  VecField(name: 'D', controller: _controllerD)
                ],
                button: ElevatedButton(onPressed: _calculate, 
                  child: Text('Делай дело four')),)
              )
            ],
          ),
          if(_answer != null) Text('Результат: $_answer', style: TextStyle(color: _answerColor))
        ],
    );
  }

  void _calculate(){
    setState(() {
      if(_controllerA.values().any((c) => c == '') ||
      _controllerB.values().any((c) => (c == '') ||
      _controllerC.values().any((c) => (c == '')) ||
      _controllerD.values().any((c) => (c == '')))) {
        _answer = 'Нужно заполнить все поля';
        _answerColor = Colors.redAccent;
      } else {
      _answer = _GeneralPlaneEquation(_controllerA.values(),
        _controllerB.values(), _controllerC.values(), _controllerD.values());
      _answerColor = Colors.blue;}
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


String _GeneralPlaneEquation(List<String> coordinatesA, List<String> coordinatesB, List<String> coordinatesC, List<String> coordinatesD){

  Plane plane = Plane.withVecAndVectors(startVec: Vec(coordinatesD.map((c) => double.parse(c)).toList()),
    vec1: Vec(coordinatesA.map((c) => double.parse(c)).toList()) - Vec(coordinatesB.map((c) => double.parse(c)).toList()),
    vec2: Vec(coordinatesA.map((c) => double.parse(c)).toList()) - Vec(coordinatesC.map((c) => double.parse(c)).toList()));
  List<double>? ABCD = plane.getGeneralEquationCoeffs();
  if(ABCD == null) throw ArgumentError('Тут потом придумаю какую ошибку кидать');
  String result = '';
  result += ABCD[0] == 0 ? '' : '${ABCD[0]}x';
  if(ABCD[1] < 0) {result += '${ABCD[1]}y';}
  else if (ABCD[1] > 0) {result += '+${ABCD[1]}y';}
  if(ABCD[2] < 0) {result += '${ABCD[2]}z';}
  else if (ABCD[2] > 0) {result += '+${ABCD[2]}z';}
  if(ABCD[3] < 0) {result += '${ABCD[3]}';}
  else if (ABCD[3] > 0) {result += '+${ABCD[3]}';}
  result += '=0';
  return result;
}
