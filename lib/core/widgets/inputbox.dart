import 'package:flutter/material.dart';
import 'package:graphic/core/widgets/pointfield.dart';

class InputBox extends StatelessWidget {
  final ButtonStyleButton? button;
  final List<VecField> fields;

  const InputBox({super.key, required this.fields, this.button});

  @override
  Widget build(BuildContext context) {
    return Column(
                  children: [
                      Container(
                        margin: EdgeInsets.only(right: 15, bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                          border: BoxBorder.all(color: Colors.black45, width: 2),),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...fields,
                          ],),
                      ),
                    ?button, 
                  ],
                );
  }
}


// setState(() {
//                       if(_controllerA.values().any((c) => c == '') ||
//                       _controllerB.values().any((c) => (c == '') ||
//                       _controllerC.values().any((c) => (c == '')))) {
//                         _answer = 'Нужно заполнить все поля';
//                         _answerColor = Colors.redAccent;
//                       } else {
//                       _answer = _GeneralLineEquation(_controllerA.values(),
//                        _controllerB.values(), _controllerC.values());
//                       _answerColor = Colors.blue;}
                    
//                     }