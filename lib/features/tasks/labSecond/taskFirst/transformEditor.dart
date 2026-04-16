import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphic/core/widgets/coordinateGrid.dart';
import 'package:graphic/core/utils/matrix3.dart';
import 'package:graphic/core/widgets/pointfield.dart';

enum TransformType { translate, scale, rotate, reflectX, reflectY, reflectYX, rotateP }

class TransformItem {
  TransformType type;
  double tx;
  double ty;
  double cx;
  double cy;
  double sx;
  double sy;
  double angle;
  bool useDegree;

  TransformItem({
    required this.type,
    this.tx = 0.0,
    this.ty = 0.0,
    this.cx = 0.0,
    this.cy = 0.0,
    this.sx = 1.0,
    this.sy = 1.0,
    this.angle = 0.0,
    this.useDegree = false,
  });

  Matrix3 toMatrix() {
    switch (type) {
      case TransformType.translate:
        return Matrix3.translation(tx, ty);
      case TransformType.scale:
        return Matrix3.scale(sx, sy);
      case TransformType.rotate:
        final radAngle = useDegree ? angle * pi / 180 : angle;
        return Matrix3.rotation(radAngle);
      case TransformType.reflectX:
        return Matrix3.reflectX();
      case TransformType.reflectY:
        return Matrix3.reflectY();
      case TransformType.reflectYX:
        return Matrix3.reflectYX();
      case TransformType.rotateP:
        final radAngle = useDegree ? angle * pi / 180 : angle;
        return Matrix3.rotationAbout(radAngle, cx, cy);
    }
  }
}

class TransformEditor extends StatefulWidget {
  final DrawablePath Figure;
  final Function(DrawablePath) onApply;

  const TransformEditor({Key? key, required this.Figure, required this.onApply})
    : super(key: key);

  @override
  State<TransformEditor> createState() => _TransformEditorState();
}

class _TransformEditorState extends State<TransformEditor> {
  List<TransformItem> _transforms = [];

  void _addTransform() {
    setState(() {
      _transforms.add(TransformItem(type: TransformType.translate));
    });
  }

  void _removeTransform(int index) {
    setState(() {
      _transforms.removeAt(index);
    });
  }

  void _moveTransform(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _transforms.removeAt(oldIndex);
      _transforms.insert(newIndex, item);
    });
  }

  void _applyTransformations() {
    if (_transforms.isEmpty) return;

    Matrix3 combined = Matrix3.identity();
    for (var t in _transforms) {
      combined = combined.multiply(t.toMatrix());
    }

    final newTransform = combined.multiply(widget.Figure.transform);

    final transformedFigure = DrawablePath(
      contours: widget.Figure.contours,
      transform: newTransform,
      paint: widget.Figure.paint,
    );

    widget.onApply(transformedFigure);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ReorderableListView.builder(
            onReorder: _moveTransform,
            itemCount: _transforms.length,
            itemBuilder: (_, i) {
              final item = _transforms[i];
              return TransformCard(
                key: ObjectKey(item),
                item: item,
                onDelete: () => _removeTransform(i),
                onTypeChanged: (newType) {
                  setState(() {
                    item.type = newType;
                    if (newType == TransformType.translate) {
                      item.tx = 0.0;
                      item.ty = 0.0;
                    } else if (newType == TransformType.scale) {
                      item.sx = 1.0;
                      item.sy = 1.0;
                    } else if (newType == TransformType.rotate) {
                      item.angle = 0.0;
                    } else if (newType == TransformType.rotateP){
                      item.angle = 0.0;
                      item.cx = 0.0;
                      item.cy = 0.0;
                    }
                  });
                },
                onAngleTypeChanged: () => setState(() {}),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: _addTransform,
            icon: const Icon(Icons.add),
            label: const Text('Добавить преобразование'),
          ),
        ),

        if (_transforms.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _applyTransformations,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Применить преобразования'),
            ),
          ),
      ],
    );
  }
}

class TransformCard extends StatelessWidget {
  final TransformItem item;
  final VoidCallback onDelete;
  final void Function(TransformType) onTypeChanged;
  final VoidCallback onAngleTypeChanged;

  const TransformCard({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onTypeChanged,
    required this.onAngleTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            SizedBox(
            width: 115,
              child: DropdownButton<TransformType>(
                value: item.type,
                items: TransformType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (newType) {
                  if (newType != null) onTypeChanged(newType);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    FocusScope.of(context).unfocus();
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            
            Expanded(child: _buildParamFields()),
            
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.red),
              onPressed: onDelete,
            ),
            SizedBox(width: 16,)
          ],
        ),
      ),
    );
  }

  Widget _buildParamFields() {
    switch (item.type) {
      case TransformType.translate:
        return Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: item.tx.toString(),
                decoration: const InputDecoration(labelText: 'dx'),
                onChanged: (v) {
                  item.tx = double.tryParse(v) ?? 0.0;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue: item.ty.toString(),
                decoration: const InputDecoration(labelText: 'dy'),
                onChanged: (v) {
                  item.ty = double.tryParse(v) ?? 0.0;
                },
              ),
            ),
          ],
        );
      case TransformType.scale:
        return Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: item.sx.toString(),
                decoration: const InputDecoration(labelText: 'sx'),
                onChanged: (v) {
                  item.sx = double.tryParse(v) ?? 1.0;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue: item.sy.toString(),
                decoration: const InputDecoration(labelText: 'sy'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (v) {
                  item.sy = double.tryParse(v) ?? 1.0;
                },
              ),
            ),
          ],
        );
      case TransformType.rotate:
        return Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: item.angle.toString(),
                decoration: InputDecoration(labelText: item.useDegree ? 'угол (град)' : 'угол (рад)'),
                onChanged: (v) {
                  item.angle = double.tryParse(v) ?? 0.0;
                },
              ),
            ),
            SizedBox(width: 8,),
            Expanded(
              child: TextButton(
                onPressed: () {
                  item.useDegree = !item.useDegree;
                  onAngleTypeChanged();
                },
                child: Align(alignment:AlignmentGeometry.centerLeft, child: Text(item.useDegree ? 'C' : 'R')),
              ),
            ),
          ],
        );
      case TransformType.rotateP:
        return Column(
    children: [
      Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: item.angle.toString(),
              decoration: InputDecoration(
                labelText: item.useDegree ? 'угол (град)' : 'угол (рад)',
              ),
              onChanged: (v) {
                item.angle = double.tryParse(v) ?? 0.0;
              },
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 48,
            child: TextButton(
              onPressed: () {
                item.useDegree = !item.useDegree;
                onAngleTypeChanged();
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(40, 40),
              ),
              child: Text(item.useDegree ? 'C' : 'R'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: item.tx.toString(),
              decoration: const InputDecoration(labelText: 'x центра'),
              onChanged: (v) {
                item.cx = double.tryParse(v) ?? 0.0;
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              initialValue: item.ty.toString(),
              decoration: const InputDecoration(labelText: 'y центра'),
              onChanged: (v) {
                item.cy = double.tryParse(v) ?? 0.0;
              },
            ),
          ),
        ],
      ),
    ],);
      case TransformType.reflectX:
      case TransformType.reflectY:
      case TransformType.reflectYX:
        return const SizedBox();
    }
  }
}
