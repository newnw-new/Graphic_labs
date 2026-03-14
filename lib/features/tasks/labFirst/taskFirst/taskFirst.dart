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
  final PointEditingController _controllerA = PointEditingController(2);
  final PointEditingController _controllerB = PointEditingController(2);
  final PointEditingController _controllerC = PointEditingController(2);

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
                PointField(name: 'A', controller: _controllerA, style: TextStyle(fontSize: 20)),
                PointField(name: 'B', controller: _controllerB, style: TextStyle(fontSize: 20)),
                PointField(name: 'C', controller: _controllerC, style: TextStyle(fontSize: 20)),
                TextButton(onPressed: () => {}, child: Text('Гоу Гоу Гоу')),
                ],)
            ],
          ),
          if(_answer != null) Text('Результат: ${_answer}')
        ],
    );
  }

  @override
  void dispose() {
    _controllerA.dispose();
    _controllerB.dispose();
    _controllerC.dispose();
    super.dispose();
  }
}