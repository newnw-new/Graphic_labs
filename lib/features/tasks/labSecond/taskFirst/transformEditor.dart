import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphic/core/widgets/coordinateGrid.dart';
import 'package:graphic/features/tasks/labSecond/matrix3.dart';

enum TransformType { translate, scale, rotate, reflectX, reflectY, reflectYX }

class TransformItem {
  TransformType type;
  double tx;
  double ty;
  double sx;
  double sy;
  double angle;

  TransformItem({
    required this.type,
    this.tx = 0.0,
    this.ty = 0.0,
    this.sx = 1.0,
    this.sy = 1.0,
    this.angle = 0.0,
  });

  Matrix3 toMatrix() {
    switch (type) {
      case TransformType.translate:
        return Matrix3.translation(tx, ty);
      case TransformType.scale:
        return Matrix3.scale(sx, sy);
      case TransformType.rotate:
        return Matrix3.rotation(angle);
      case TransformType.reflectX:
        return Matrix3.reflectX();
      case TransformType.reflectY:
        return Matrix3.reflectY();
      case TransformType.reflectYX:
        return Matrix3.reflectYX();
    }
  }
}

/// Виджет, позволяющий редактировать последовательность преобразований
/// и применять их к исходной фигуре.
class TransformEditor extends StatefulWidget {
  final DrawableFigure Figure;
  final Function(DrawableFigure) onApply;

  const TransformEditor({
    Key? key,
    required this.Figure,
    required this.onApply,
  }) : super(key: key);

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

    final transformedFigure = DrawableFigure(
      contours: widget.Figure.contours,
      transform: newTransform,
      paint: widget.Figure.paint,
      closed: widget.Figure.closed,
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
                    }
                  });
                },
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
        // Кнопка применения (показывается только когда есть преобразования)
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

  const TransformCard({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      //margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // Выбор типа преобразования
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
            const SizedBox(width: 12),
            // Параметры в зависимости от типа
            SizedBox(width: 87, child: _buildParamFields()),
            // Кнопка удаления
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.red),
              onPressed: onDelete,
            ),
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
        return TextFormField(
          initialValue: item.angle.toString(),
          decoration: const InputDecoration(labelText: 'угол (рад)'),
          onChanged: (v) {
            final angle = double.tryParse(v) ?? 0.0;
            item.angle = angle == 0 ? 0.0 : -angle;
          },
        );
      case TransformType.reflectX:
      case TransformType.reflectY:
      case TransformType.reflectYX:
        return const SizedBox();
    }
  }
}
