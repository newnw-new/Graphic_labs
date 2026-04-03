import 'dart:typed_data';
import 'dart:ui';
import 'dart:math';

class Matrix3 {
  late final List<List<double>> _elements;

  Matrix3._init(this._elements);

  factory Matrix3(List<List<double>> elements) {
    if (elements.length != 3 && 
    elements[0].length !=3 && elements[1].length !=3 && elements[2].length != 3) {
      throw ArgumentError('Matrix3 должна быть 3x3');
    }

    return Matrix3._init(elements);
  }

  factory Matrix3.identity() {
    return Matrix3._init([[1, 0, 0], [0, 1, 0], [0, 0, 1]]);
  }

  factory Matrix3.translation(double tx, double ty) {
    return Matrix3._init([
      [1, 0, 0],
      [0, 1, 0],
      [tx, ty, 1],
    ]);
  }

  /// Матрица масштабирования.
  factory Matrix3.scale(double sx, double sy){
    return Matrix3._init([
        [sx, 0, 0],
        [0, sy, 0],
        [0, 0, 1],
      ]);
    }

  /// Матрица поворота (угол в радианах).
  factory Matrix3.rotation(double angle) {
    final c = cos(angle);
    final s = sin(angle);
    return Matrix3._init([
      [c, -s, 0],
      [s, c, 0],
      [0, 0, 1],
    ]);
  }

  factory Matrix3.reflectX() => Matrix3.scale(1, -1);

  factory Matrix3.reflectY() => Matrix3.scale(-1, 1);

  factory Matrix3.reflectYX(){
    return Matrix3._init([
        [0, 1, 0],
        [1, 0, 0],
        [0, 0, 1],
      ]);
    }

  Offset transform(Offset point) {
    final x = point.dx;
    final y = point.dy;
    final newX = _elements[0][0] * x + _elements[1][0] * y + _elements[2][0];
    final newY = _elements[0][1] * x + _elements[1][1] * y + _elements[2][1];

    return Offset(newX, newY);
  }


  Matrix3 translate(double tx, double ty) =>
      multiply(Matrix3.translation(tx, ty));

  Matrix3 scale(double sx, double sy) => multiply(Matrix3.scale(sx, sy));

  Matrix3 rotate(double angle) => multiply(Matrix3.rotation(angle));

  Matrix3 reflectX() => multiply(Matrix3.reflectX());

  Matrix3 reflectY() => multiply(Matrix3.reflectY());

  Matrix3 reflectYX() => multiply(Matrix3.reflectYX());


  Matrix3 operator * (Matrix3 matrix){

    final result = List.generate(3, (_) => List<double>.filled(3, 0.0));

    for (int i = 0; i < 3; ++i) {
      for (int j = 0; j < 3; ++j) {
        double sum = 0.0;
        for (int k = 0; k < 3; ++k) {
          sum += _elements[i][k] * matrix._elements[k][j];
        }
        result[i][j] = sum;
      }
    }

    return Matrix3._init(result);
  }

  Matrix3 multiply(Matrix3 matrix) => this*matrix;

}
