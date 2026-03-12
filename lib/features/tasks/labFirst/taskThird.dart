import 'package:flutter/material.dart';

class TaskThird extends StatefulWidget {
  const TaskThird({super.key});

  @override
  State<TaskThird> createState() => _TaskThirdState();
}

class _TaskThirdState extends State<TaskThird> {
  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(16),
      child: Text('Задание 3'));
  }
}