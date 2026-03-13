import 'package:flutter/material.dart';

//Тут нужно задать логику переноса, добавить валидацию
//и возможность изменить размер этого виджета

class PointField extends StatefulWidget {
  final String name;
  final int dimension;

  const PointField({super.key, required this.name, required this.dimension});

  @override
  State<PointField> createState() => PointFieldState();
}

class PointFieldState extends State<PointField> {
// разобраться с модификатором late
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    _controllers = List.generate(widget.dimension,
      (_) => TextEditingController(),);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text('${widget.name}('),
      ..._buildCoordinateFields(),
      Text(')'),
    ],);
  }

   List<Widget> _buildCoordinateFields() {
    final List<Widget> fields = [];
    for (int i = 0; i < widget.dimension; i++) {
      
      fields.add(
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 50),
          child: IntrinsicWidth(
            child: TextField(
              controller: _controllers[i],
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
        ),
      );
      
      if (i < widget.dimension - 1) {
        fields.add(const Text(','));
      }
    }
    return fields;
  }

  @override
  void dispose() {
    for(int i = 0; i < widget.dimension; ++i){
      _controllers[i].dispose();
    }
    super.dispose();
  }

  List<double> getCoordinates(){
    return _controllers.map((c) => double.parse(c.text)).toList();
  }
}