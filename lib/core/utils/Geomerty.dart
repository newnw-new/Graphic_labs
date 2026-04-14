import 'dart:math';
import 'dart:ui' show Offset;

class Vec extends Matrix{
  final List<double> _coordinates;

  Vec(this._coordinates) : super._init([_coordinates]) {
    if (_coordinates.isEmpty) {
      throw ArgumentError('Нельзя создать точку без координат');
    }
  }

  factory Vec.fromOffset(Offset offset){
    return Vec([offset.dx, offset.dy, 1]);
  }

  List<double> get coordinates => _coordinates;

  double euclideanNorm() {
    double sum = 0;
    for (int i = 0; i < _coordinates.length; ++i) {
      sum += _coordinates[i] * _coordinates[i];
    }
    return sqrt(sum);
  }

  double euclideanNorm2() {
    double sum = 0;
    for (int i = 0; i < _coordinates.length; ++i) {
      sum += _coordinates[i] * _coordinates[i];
    }
    return sum;
  }

  Offset toOffset(){
    if(_coordinates.length < 2) throw ArgumentError('Да трындец');

    return Offset(_coordinates[0], _coordinates[1]);
  }

  @override
  Vec operator +(Matrix b) {
    if(!(b is Vec)) throw ArgumentError('Vector можно складывать только с другим Vector');
    if (this._coordinates.length != b._coordinates.length)
      throw ArgumentError('Векторы разных размерностей');
    return Vec(
      List.generate(
        this._coordinates.length,
        (i) => this._coordinates[i] + b._coordinates[i],
      ),
    );
  }


  @override
  Vec operator -() {
    return Vec(
      List.generate(this._coordinates.length, (i) => -this._coordinates[i]),
    );
  }

  @override
  Vec operator -(Matrix b) {
    return this + (-b);
  }
}

class Line {
  final Vec _O;
  final Vec _vec;

  Line.withStartVecAndVec({required Vec startVec, required Vec vec})
    : _O = startVec,
      _vec = vec {
    if (vec.coordinates.every((c) => c == 0)) {
      throw ArgumentError('Направляющий вектор не может быть нулевым');
    }
  }

  factory Line.withTwoVecs(Vec A1, Vec A2) {
    if (A1.coordinates.length != A2.coordinates.length) {
      throw ArgumentError('Размерность точек не совпадает');
    }

    final Vec directVec = Vec(
      List.generate(
        A1.coordinates.length,
        (i) => A1.coordinates[i] - A2.coordinates[i],
      ),
    );

    return Line.withStartVecAndVec(startVec: A1, vec: directVec);
  }

  List<double>? getGeneralEquationCoeffs() {
    if (_O.coordinates.length != 2 || _vec.coordinates.length != 2) {
      return null;
    }

    final double A = _vec.coordinates[1];
    final double B = -_vec.coordinates[0];
    final double C =
        _vec.coordinates[0] * _O.coordinates[1] -
        _O.coordinates[0] * _vec.coordinates[1];

    return [A, B, C];
  }

  bool VecAtLine(Vec A) {
    if (A.coordinates.length != _O.coordinates.length) return false;

    final AO = A - _O;

    if ((scalarProduct(AO, _vec)!.abs() -
                AO.euclideanNorm() * _vec.euclideanNorm())
            .abs() <
        1e-6)
      return true;
    else
      return false;
  }
}

class Plane {
  final Vec _O;
  final Vec _vec1;
  final Vec _vec2;

  Plane._init({required Vec startVec, required Vec vec1, required Vec vec2})
    : _O = startVec,
      _vec1 = vec1,
      _vec2 = vec2;

  factory Plane.withVecAndVectors({
    required Vec startVec,
    required Vec vec1,
    required Vec vec2,
  }) {
    if (vec1.coordinates.every((c) => c == 0) ||
        vec2.coordinates.every((c) => c == 0)) {
      throw ArgumentError('Направляющий вектор не может быть нулевым');
    }

    if (vec1.coordinates.length != vec2.coordinates.length ||
        vec1.coordinates.length != startVec.coordinates.length) {
      throw ArgumentError('Разные размерности у аргументов');
    }

    if ((scalarProduct(vec1, vec2)!.abs() -
                vec1.euclideanNorm() * vec2.euclideanNorm())
            .abs() <
        1e-6) {
      throw ArgumentError('Векторы коллинеарны');
    }

    return Plane._init(startVec: startVec, vec1: vec1, vec2: vec2);
  }

  factory Plane.withThreeVecs(Vec A1, Vec A2, Vec A3) {
    if (A1.coordinates.length != A2.coordinates.length ||
        A1.coordinates.length != A3.coordinates.length) {
      throw ArgumentError('Размерность точек не совпадает');
    }

    final Vec directVec1 = Vec(
      List.generate(
        A1.coordinates.length,
        (i) => A1.coordinates[i] - A2.coordinates[i],
      ),
    );
    final Vec directVec2 = Vec(
      List.generate(
        A1.coordinates.length,
        (i) => A1.coordinates[i] - A3.coordinates[i],
      ),
    );

    return Plane.withVecAndVectors(
      startVec: A1,
      vec1: directVec1,
      vec2: directVec2,
    );
  }

  List<double>? getGeneralEquationCoeffs() {
    if (_O.coordinates.length != 3 ||
        _vec1.coordinates.length != 3 ||
        _vec2.coordinates.length != 3) {
      return null;
    }

    final v1 = _vec1.coordinates;
    final v2 = _vec2.coordinates;

    final A = v1[1] * v2[2] - v1[2] * v2[1];
    final B = v1[2] * v2[0] - v1[0] * v2[2];
    final C = v1[0] * v2[1] - v1[1] * v2[0];
    final O = _O.coordinates;
    final D = -(A * O[0] + B * O[1] + C * O[2]);

    return [A, B, C, D];
  }
}

double? scalarProduct(Vec vec1, Vec vec2) {
  if (vec1.coordinates.length != vec2.coordinates.length) return null;

  double result = 0;

  for (int i = 0; i < vec1.coordinates.length; ++i) {
    result += vec1.coordinates[i] * vec2.coordinates[i];
  }

  return result;
}

class Matrix {
  final List<List<double>> elements;

  Matrix(this.elements){
    if (elements.isEmpty){ throw ArgumentError('Дан пустой массив для задания матрицы');}

    final rowsCount = elements.length;
    final columnsCount = elements[0].length;

    for (int i = 0; i < rowsCount; ++i){
      if (elements[i].isEmpty || elements[i].length != columnsCount) {
        throw ArgumentError('Задан неккоректный размер матрицы. Строки имеют разное число элементов');
      }
    }
  }

  Matrix._init(this.elements);

  List<List<double>> get matrixElements => elements.map((row) => List<double>.from(row)).toList();

  Matrix operator *(Matrix matrix){

    final rows1 = elements.length;
    final cols1 = elements[0].length;
    final rows2 = matrix.elements.length;
    final cols2 = matrix.elements[0].length;

    if (cols1 != rows2) {
      throw ArgumentError(
        'Умножение невозможно: количество столбцов первой матрицы ($cols1) '
        'не равно количеству строк второй ($rows2)',
      );
    }

    final resultRows = List.generate(rows1, (_) => List<double>.filled(cols2, 0.0));

    for (int i = 0; i < rows1; ++i) {
      for (int j = 0; j < cols2; ++j) {
        double sum = 0.0;
        for (int k = 0; k < cols1; ++k) {
          sum += elements[i][k] * matrix.elements[k][j];
        }
        resultRows[i][j] = sum;
      }
    }

    return Matrix(resultRows);
  }

  Matrix scaleScalar(double scalar){
    List<List<double>> newList = elements.map((row) => List<double>.from(row)).toList();
    for(int i = 0; i < newList.length; ++i){
      for(int j = 0; j < newList[i].length; ++j){
        newList[i][j] *= scalar;
      }
    }

    return Matrix(newList);
  }

  Matrix operator +(Matrix matrix){
    if(matrix.elements.length != elements.length) {
      throw ArgumentError('Для сложения была дана матрица с другим количеством строк');
    }

    for(int i = 0; i < elements.length; ++i){
      if(matrix.elements[i].length != elements[i].length){
        throw ArgumentError('Для сложения была дана матрица с другим количеством столбцов');      
      }
    }

    List<List<double>> newElements = elements.map((row) => List<double>.from(row)).toList();
    
    for(int i = 0; i < newElements.length; ++i){
      for(int j = 0; j < newElements[i].length; ++j){
        newElements[i][j] += matrix.elements[i][j];
      }
    }

    return Matrix(newElements);
  }

  Matrix operator -(){
    List<List<double>> newElements = elements.map((row) => _negativeList(row)).toList();
    return Matrix(newElements);
  }

  Matrix operator -(Matrix matrix){
    return this + -(matrix);
  }

  List<double> _negativeList (List<double> list){
    return list.map((e) => -e).toList();
  }
}
