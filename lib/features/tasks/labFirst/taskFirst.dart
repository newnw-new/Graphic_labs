import 'package:flutter/material.dart';
import 'package:graphic/core/widgets/pointfield.dart';
import 'package:graphic/core/utils/Geomerty.dart';
import 'package:graphic/core/widgets/inputbox.dart';

class TaskFirst extends StatefulWidget {
  const TaskFirst({super.key});

  @override
  State<TaskFirst> createState() => _TaskFirstState();
}

class _TaskFirstState extends State<TaskFirst> {
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
            padding: const EdgeInsets.only(left: 20, right: 8, top: 20, bottom: 20),
            child: Text('Задание 1. Вариант 2. Даны точки А, В, С своими координатами, найти уравнение прямой проходящей через точку С и параллельную прямой АВ.',
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
                child: InputBox(fields: 
                  [VecField(name: 'A', controller: _controllerA),
                  VecField(name: 'B', controller: _controllerB),
                  VecField(name:'C', controller: _controllerC,)],
                  button: ElevatedButton(onPressed: _calculate, child: Text('Делай дело раз')),
                )
              )
            ],
          ),
          if(_answer != null) Text('Результат: $_answer', style: TextStyle(color: _answerColor))
        ],
    );
    
  }

  void _calculate(){
    setState( () {
      if(_controllerA.values().any((c) => c == '') ||
      _controllerB.values().any((c) => (c == '') ||
      _controllerC.values().any((c) => (c == '')))) {
        _answer = 'Нужно заполнить все поля';
        _answerColor = Colors.redAccent;
      } else {
      _answer = _GeneralLineEquation(_controllerA.values(),
        _controllerB.values(), _controllerC.values());
      _answerColor = Colors.blue;}});
  }

  @override
  void dispose() {
    _controllerA.dispose();
    _controllerB.dispose();
    _controllerC.dispose();
    super.dispose();
  }
}


String _GeneralLineEquation(List<String> coordinatesA, List<String> coordinatesB, List<String> coordinatesC){

  Line line = Line.withStartVecAndVec(startVec: Vec(coordinatesC.map((c) => double.parse(c)).toList()),
    vec: Vec(coordinatesA.map((c) => double.parse(c)).toList())
     - Vec(coordinatesB.map((c) => double.parse(c)).toList()));
  List<double>? ABC = line.getGeneralEquationCoeffs();
  if(ABC == null) throw ArgumentError('Тут потом придумаю какую ошибку кидать');
  String result = '';
  result += ABC[0] == 0 ? '' : '${ABC[0]}x';
  if(ABC[1] < 0) {result += '${ABC[1]}y';}
  else if (ABC[1] > 0) {result += '+${ABC[1]}y';}
  if(ABC[2] < 0) {result += '${ABC[2]}';}
  else if (ABC[2] > 0) {result += '+${ABC[2]}';}
  result += '=0';
  return result;
}