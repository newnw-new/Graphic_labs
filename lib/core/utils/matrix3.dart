import 'dart:ui';
import 'dart:math';

import 'package:graphic/core/utils/Geomerty.dart';

class Matrix3 extends Matrix {
  Matrix3._init(super.elements);

  Matrix3(List<List<double>> elements) : super(elements) {
    if (elements.length != 3 &&
        elements[0].length != 3 &&
        elements[1].length != 3 &&
        elements[2].length != 3) {
      throw ArgumentError('Matrix3 должна быть 3x3');
    }
  }

  factory Matrix3.identity() {
    return Matrix3._init([
      [1, 0, 0],
      [0, 1, 0],
      [0, 0, 1],
    ]);
  }

  factory Matrix3.translation(double rx, double ry) {
    return Matrix3._init([
      [1, 0, rx],
      [0, 1, ry],
      [0, 0, 1],
    ]);
  }

  factory Matrix3.scale(double sx, double sy) {
    return Matrix3._init([
      [sx, 0, 0],
      [0, sy, 0],
      [0, 0, 1],
    ]);
  }

  factory Matrix3.rotation(double angle) {
    final c = cos(angle);
    final s = sin(angle);
    return Matrix3._init([
      [c, -s, 0],
      [s, c, 0],
      [0, 0, 1],
    ]);
  }

  factory Matrix3.rotationAbout(double angle, double cx, double cy) {
    final toCenter = Matrix3.translation(cx, cy);
    final rotation = Matrix3.rotation(angle);
    final fromCenter = Matrix3.translation(-cx, -cy);
    return toCenter * rotation * fromCenter;
  }

  factory Matrix3.reflectX() => Matrix3.scale(1, -1);

  factory Matrix3.reflectY() => Matrix3.scale(-1, 1);

  factory Matrix3.reflectYX() {
    return Matrix3._init([
      [0, 1, 0],
      [1, 0, 0],
      [0, 0, 1],
    ]);
  }

  Matrix3 translate(double tx, double ty) =>
      multiply(Matrix3.translation(tx, ty));

  Matrix3 scale(double sx, double sy) => multiply(Matrix3.scale(sx, sy));

  Matrix3 rotate(double angle) => multiply(Matrix3.rotation(angle));

  Matrix3 rotateAbout(double angle, double cx, double cy) {
    final toCenter = Matrix3.translation(-cx, -cy);
    final rotation = Matrix3.rotation(angle);
    final fromCenter = Matrix3.translation(cx, cy);
    return toCenter * rotation * fromCenter * this;
  }

  Matrix3 reflectX() => multiply(Matrix3.reflectX());

  Matrix3 reflectY() => multiply(Matrix3.reflectY());

  Matrix3 reflectYX() => multiply(Matrix3.reflectYX());

  @override
  Matrix3 operator *(Matrix matrix) {
    if (matrix is! Matrix3)
      throw ArgumentError('Matrix3 можно умножать только на Matrix3');
    final result = List.generate(3, (_) => List<double>.filled(3, 0.0));

    for (int i = 0; i < 3; ++i) {
      for (int j = 0; j < 3; ++j) {
        double sum = 0.0;
        for (int k = 0; k < 3; ++k) {
          sum += super.elements[i][k] * matrix.elements[k][j];
        }
        result[i][j] = sum;
      }
    }

    return Matrix3._init(result);
  }

  Matrix3 multiply(Matrix3 matrix) => this * matrix;

  Vec multiplyOnVec(Vec vec) {
    if (vec.coordinates.length != 3)
      throw ArgumentError('Vec должен быть размерности 3');
    List<double> result = List.filled(3, 0);

    for (int i = 0; i < 3; ++i) {
      for (int j = 0; j < 3; ++j) {
        result[i] += elements[i][j] * vec.coordinates[j];
      }
    }

    return Vec(result);
  }
}
