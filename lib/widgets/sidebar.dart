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
                        onTap: () => {},
                      ),
                      ListTile(
                        title: SidebarText('Задание 2'),
                        onTap: () => {},
                      ),
                      ListTile(
                        title: SidebarText('Задание 3'),
                        onTap: () => {},
                      ),
                      ListTile(
                        title: SidebarText('Задание 4'),
                        onTap: () => {},
                      ),
                    ],  
                  ),
                  ExpansionTile(
                    title: SidebarText('Лабораторная 2'),
                    children: [
                      ListTile(
                        title: SidebarText('Задание 1'),
                        onTap: () => {},
                      ),
                      ListTile(
                        title: SidebarText('Задание 2'),
                        onTap: () => {},
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

