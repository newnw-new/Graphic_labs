import 'package:flutter/material.dart';

class TaskSecond extends StatefulWidget {
  const TaskSecond({super.key});

  @override
  State<TaskSecond> createState() => _TaskSecondState();
}

class _TaskSecondState extends State<TaskSecond> {
  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(16),
      child: Text('Задание второе'));
  }
}