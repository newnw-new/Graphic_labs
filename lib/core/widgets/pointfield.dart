import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//Тут нужно задать логику переноса, добавить валидацию
//и возможность изменить размер этого виджета

class VecField extends StatefulWidget {
  final String name;
  final VecEditingController controller;
  final TextStyle? style;

  const VecField({super.key, required this.name, required this.controller, this.style});

  @override
  State<VecField> createState() => VecFieldState();
}

class VecFieldState extends State<VecField> {

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text('${widget.name}(', style: widget.style),
      ..._buildCoordinateFields(),
      Text(')', style: widget.style),
    ],);
  }

   List<Widget> _buildCoordinateFields() {
    final List<Widget> fields = [];
    for (int i = 0; i < widget.controller.controllers.length; i++) {
      
      fields.add(
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 10, maxWidth: 50),
          child: IntrinsicWidth(
            child: TextField(
              controller: widget.controller.controllers[i],
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
              ],
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
        ),
      );
      
      if (i < widget.controller.controllers.length - 1) {
        fields.add(const Text(','));
      }
    }
    return fields;
  }

  @override
  void dispose() {
    for(int i = 0; i < widget.controller.controllers.length; ++i){
      widget.controller.controllers[i].dispose();
    }
    super.dispose();
  }

}


class VecEditingController {
  final List<TextEditingController> controllers;

  //Разобраться что за синтаксис с двоеточием
  VecEditingController(int dimension)
  : controllers = List.generate(dimension,
      (_) => TextEditingController(),);

  List<String> values() => controllers.map((c) => c.text).toList();

  void dispose() {
    for (var c in controllers) c.dispose();
  }
}