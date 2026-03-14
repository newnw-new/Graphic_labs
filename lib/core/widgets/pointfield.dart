import 'package:flutter/material.dart';

//Тут нужно задать логику переноса, добавить валидацию
//и возможность изменить размер этого виджета

class PointField extends StatefulWidget {
  final String name;
  final PointEditingController controller;
  final TextStyle? style;

  const PointField({super.key, required this.name, required this.controller, this.style});

  @override
  State<PointField> createState() => PointFieldState();
}

class PointFieldState extends State<PointField> {

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
          constraints: const BoxConstraints(maxWidth: 50),
          child: IntrinsicWidth(
            child: TextField(
              controller: widget.controller.controllers[i],
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


class PointEditingController {
  final List<TextEditingController> controllers;

  //Разобраться что за синтаксис с двоеточием
  PointEditingController(int dimension)
  : controllers = List.generate(dimension,
      (_) => TextEditingController(),);

  List<String> values() => controllers.map((c) => c.text).toList();

  void dispose() {
    for (var c in controllers) c.dispose();
  }
}