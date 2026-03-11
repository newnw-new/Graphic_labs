import 'package:flutter/material.dart';

class Sidebar extends StatefulWidget {
  const Sidebar ({super.key});
  
  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  @override
  Widget build(BuildContext context) {
    
    return FractionallySizedBox(
      widthFactor: 1/3,
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(252, 252, 253, 1),
          borderRadius: BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(15)),
          boxShadow: [BoxShadow(blurRadius: 15, color:Colors.black)],
        ),
        padding: EdgeInsets.only(top: 30, bottom: 20, left: 40, right: 40),
        child: ListView(
          children: [
            Center(child: Text('Лабораторная 1')),
            Center(child: Text('Задание 1')),
            Center(child: Text('Задание 1')),
            Center(child: Text('Задание 1')),
            Center(child: Text('Задание 1')),
            Center(child: Text('Задание 1')),
            Center(child: Text('Задание 1')),
            Center(child: Text('Задание 1')),
            Center(child: Text('Задание 1')),
            Center(child: Text('Задание 1')),
            Center(child: Text('Задание 1')),
            Center(child: Text('Задание 1')),
            Center(child: Text('Задание 1')),
            Center(child: Text('Задание 1')),
            Center(child: Text('Задание 1')),
            Center(child: Text('Задание 1')),
            Center(child: Text('Задание 1')),
            Center(child: Text('Задание 1')),
            Center(child: Text('Задание 1')),
            Center(child: Text('Задание 1')),
            Center(child: Text('Задание 1')),
            Center(child: Text('Задание 1')),
            Center(child: Text('Задание 1')),
            Center(child: Text('Задание 1')),
            Center(child: Text('Задание 1')),
            Center(child: Text('Задание 1')),
            Center(child: Text('Задание 1')),
            Center(child: Text('Задание 1')),
            Center(child: Text('Задание 1')),
            Center(child: Text('Задание 1')),
            Center(child: Text('Задание 1')),
            Center(child: Text('Задание 1')),
            Center(child: Text('Задание 1')),
          ],
        ),
      ),
    );
  }
} 

