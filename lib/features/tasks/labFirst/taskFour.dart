import 'package:flutter/material.dart';

class TaskFour extends StatefulWidget {
  const TaskFour({super.key});

  @override
  State<TaskFour> createState() => _TaskFourState();
}

class _TaskFourState extends State<TaskFour> {
  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(16),
      child: Text('Задание 4'));
  }
}