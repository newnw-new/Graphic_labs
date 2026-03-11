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
        color:Color.fromRGBO(0, 255, 0, 0),
        child: ListView(
          children: [
            Text('TestText')
          ],
        ),
      ),
    );
  }
} 

