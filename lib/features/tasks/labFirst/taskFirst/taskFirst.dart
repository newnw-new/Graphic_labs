import 'package:flutter/material.dart';
import 'package:graphic/core/widgets/pointfield.dart';
import 'package:graphic/features/tasks/labFirst/taskFirst/logic.dart';

class TaskFirst extends StatefulWidget {
  const TaskFirst({super.key});

  @override
  State<TaskFirst> createState() => _TaskFirstState();
}

class _TaskFirstState extends State<TaskFirst> {
  String? _answer = null;
  final GlobalKey<PointFieldState> _aKey = GlobalKey();
  final GlobalKey<PointFieldState> _bKey = GlobalKey();
  final GlobalKey<PointFieldState> _cKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 8, top: 20, bottom: 20),
            child: Text('Вариант 2. Даны точки А, В, С своими координатами, найти уравнение прямой проходящей через точку С и параллельную прямой АВ.',
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                PointField(key: _aKey, name: 'A', dimension: 2,),
                PointField(key: _bKey, name: 'B', dimension: 2,),
                PointField(key: _cKey, name: 'C', dimension: 2,),
                TextButton(onPressed: () => {setState(() {
                  _answer = LineEquation.withPointAndVector(
                    O: Point(x: _cKey.currentState!.getCoordinates()[0], y: _cKey.currentState!.getCoordinates()[1]),
                    vec: Point(x: _aKey.currentState!.getCoordinates()[0] - _bKey.currentState!.getCoordinates()[0],
                      y: _aKey.currentState!.getCoordinates()[1] - _bKey.currentState!.getCoordinates()[1])).getStringFormat();
                  })}, child: Text('Гоу Гоу Гоу')),
                ],)
            ],
          ),
          if(_answer != null) Text('Результат: ${_answer}')
        ],
    );
  }
}