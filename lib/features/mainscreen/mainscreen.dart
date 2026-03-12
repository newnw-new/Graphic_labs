import 'package:flutter/material.dart';
import 'package:graphic/features/sidebar/sidebar.dart';
import 'package:graphic/features/tasks/labFirst/taskFirst.dart';
import 'package:graphic/features/tasks/labFirst/taskFour.dart';
import 'package:graphic/features/tasks/labFirst/taskSecond.dart';
import 'package:graphic/features/tasks/labFirst/taskThird.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.title});

  final String title;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _currentTask = 'task1';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        
        title: Text(widget.title),
      ),
      body: Row(
        children: [
          Expanded(flex: 1, child: Sidebar(onTaskSelect: _onTaskSelected,)),
          Expanded(flex: 2, child: _buildTask(_currentTask))
        ],
      )
    );
  }

  void _onTaskSelected(String taskId){
    setState(() {
      _currentTask = taskId;
    });
  }

  Widget _buildTask(String taskId){
    switch(taskId){
      case 'task1': return const TaskFirst();
      case 'task2': return const TaskSecond();
      case 'task3': return const TaskThird();
      case 'task4': return const TaskFour();
      default: return Text('Не получилось');
    }
  }
}