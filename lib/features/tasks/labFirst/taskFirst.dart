import 'package:flutter/material.dart';
import 'package:graphic/core/widgets/pointinput.dart';

class TaskFirst extends StatefulWidget {
  const TaskFirst({super.key});

  @override
  State<TaskFirst> createState() => _TaskFirstState();
}

class _TaskFirstState extends State<TaskFirst> {
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
                Align(alignment: Alignment.centerLeft, child: PointInput(name: 'A', dimension: 2,)),
                Align(alignment: Alignment.centerLeft, child: PointInput(name: 'B', dimension: 2,)),
                Align(alignment: Alignment.centerLeft, child: PointInput(name: 'C', dimension: 2,)),],)
            ],
          ),
        ],
    );
  }
}