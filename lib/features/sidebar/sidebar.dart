import 'package:flutter/material.dart';

class Sidebar extends StatefulWidget {
  final Function(String taskId) onTaskSelect;
  const Sidebar ({super.key, required this.onTaskSelect});
  
  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  @override
  Widget build(BuildContext context) {
    
    return FractionallySizedBox(
      //widthFactor: 1/3,
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(252, 252, 253, 1),
          borderRadius: BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(15)),
          boxShadow: [BoxShadow(blurRadius: 15, color:Colors.black)],
        ),
        padding: EdgeInsets.only(top: 30, bottom: 20, left: 40, right: 40),
        child: Column(
          children: [
            SidebarText('Содержание'),
            SizedBox(height: 20,),
            Expanded(
              child: ListView(
                children: [
                  ExpansionTile(
                    title: SidebarText('Лабораторная 1'),
                    children: [
                      ListTile(
                        title: SidebarText('Задание 1'),
                        onTap: () => {widget.onTaskSelect('task1')},
                      ),
                      ListTile(
                        title: SidebarText('Задание 2'),
                        onTap: () => {widget.onTaskSelect('task2')},
                      ),
                      ListTile(
                        title: SidebarText('Задание 3'),
                        onTap: () => {widget.onTaskSelect('task3')},
                      ),
                      ListTile(
                        title: SidebarText('Задание 4'),
                        onTap: () => {widget.onTaskSelect('task4')},
                      ),
                    ],  
                  ),
                  ExpansionTile(
                    title: SidebarText('Лабораторная 2'),
                    children: [
                      ListTile(
                        title: SidebarText('Задание 1'),
                        onTap: () => {widget.onTaskSelect('task5')},
                      ),
                      ListTile(
                        title: SidebarText('Задание 2'),
                        onTap: () => {widget.onTaskSelect('task6')},
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: SidebarText('Лабораторная 3'),
                    children: [
                      ListTile(
                        title: SidebarText('Задание 1'),
                        onTap: () => {widget.onTaskSelect('task7')},
                      ),
                      ListTile(
                        title: SidebarText('Задание 2'),
                        onTap: () => {widget.onTaskSelect('task8')},
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: SidebarText('Лабораторная 4'),
                    children: [
                      ListTile(
                        title: SidebarText('Задание 1'),
                        onTap: () => {widget.onTaskSelect('task9')},
                      ),
                      ListTile(
                        title: SidebarText('Задание 2'),
                        onTap: () => {widget.onTaskSelect('task10')},
                      ),
                      ListTile(
                        title: SidebarText('Задание 3'),
                        onTap: () => {widget.onTaskSelect('task11')},
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: SidebarText('Лабораторная 5'),
                    children: [
                      ListTile(
                        title: SidebarText('Задание 1'),
                        onTap: () => {widget.onTaskSelect('task12')},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget SidebarText (String text){
    return Text(text, 
      style: TextStyle(
        color: Colors.black,
        fontFamily: 'Inter',
        fontSize: 20,
      ),    
    );
  }
} 

