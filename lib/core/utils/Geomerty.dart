import 'dart:math';

class Point {
  
  final List<double> _coordinates;

  Point(List<double> coordinates) : _coordinates = coordinates
  {
    if(coordinates.isEmpty){
      throw ArgumentError('Нельзя создать точку без координат');
    }
  }

  List<double> coordinates() => _coordinates;

  double euclideanNorm(){
    double sum = 0;
    for (int i = 0; i < _coordinates.length; ++i){
      sum += _coordinates[i]*_coordinates[i];
    }
    return sqrt(sum);
  }
}

class Line {
  final Point _O;
  final Point _vec;

  Line.withStartPointAndVec({required Point startPoint, required Point vec})
    : _O = startPoint, _vec = vec
  {
    if(vec.coordinates().every((c) => c == 0)) {
      throw ArgumentError('Направляющий вектор не может быть нулевым');
    }
  }


  factory Line.withTwoPoints(Point A1, Point A2)
  {
    if(A1.coordinates().length != A2.coordinates().length){
      throw ArgumentError('Размерность точек не совпадает');
    }

    final Point directVec = Point(List.generate(A1.coordinates().length,
      (i) => A1.coordinates()[i] - A2.coordinates()[i]));

    return Line.withStartPointAndVec(startPoint: A1, vec: directVec);
  }

  List<double>? getGeneralEquationCoeffs(){
    if (_O.coordinates().length != 2 || _vec.coordinates().length != 2) {
      return null;
    } 

    final double A = _vec.coordinates()[1];
    final double B = -_vec.coordinates()[0];
    final double C = _vec.coordinates()[0]*_O.coordinates()[1] - _O.coordinates()[0]*_vec.coordinates()[1];

    return [A, B, C];
  }

  bool pointAtLine (Point A){
    if (A.coordinates().length != _O.coordinates().length) return false;
    double findT(int coord) => (A.coordinates()[coord] - _O.coordinates()[coord])/_vec.coordinates()[coord];
    final double t = findT(0);

    for(int i = 1; i < A.coordinates().length; ++i){
      if((t - findT(i)).abs() < 1e-6) return false;
    }

    return true;
  }
  
}

class Plane {
  final Point _O;
  final Point _vec1;
  final Point _vec2;

  Plane._init({required Point startPoint, required Point vec1, required Point vec2})
    : _O = startPoint, _vec1 = vec1, _vec2 = vec2;

  factory Plane.withPointAndVectors({required Point startPoint, required Point vec1, required Point vec2})
  {
    if(vec1.coordinates().every((c) => c == 0) || vec2.coordinates().every((c) => c == 0)) {
      throw ArgumentError('Направляющий вектор не может быть нулевым');
    }

    if(vec1.coordinates().length != vec2.coordinates().length 
      || vec1.coordinates().length != startPoint.coordinates().length) {
      throw ArgumentError('Разные размерности у аргументов');
    }

    if((scalarProduct(vec1, vec2)!.abs() - vec1.euclideanNorm()*vec2.euclideanNorm()).abs() < 1e-6){
      throw ArgumentError('Векторы коллинеарны');
    }

    return Plane._init(startPoint: startPoint, vec1: vec1, vec2: vec2);
  }


  factory Plane.withThreePoints(Point A1, Point A2, Point A3)
  {
    if(A1.coordinates().length != A2.coordinates().length 
      || A1.coordinates().length != A3.coordinates().length){
      throw ArgumentError('Размерность точек не совпадает');
    }

    final Point directVec1 = Point(List.generate(A1.coordinates().length, 
      (i) => A1.coordinates()[i] - A2.coordinates()[i]));
    final Point directVec2 = Point(List.generate(A1.coordinates().length, 
    (i) => A1.coordinates()[i] - A3.coordinates()[i]));

    return Plane.withPointAndVectors(startPoint: A1, vec1: directVec1, vec2: directVec2);
  }

  List<double>? getGeneralEquationCoeffs(){
    if (_O.coordinates().length != 3 
      || _vec1.coordinates().length != 3
      || _vec2.coordinates().length != 3) {
      return null;
    } 
    

    //Разобраться почему так
    final v1 = _vec1.coordinates();
    final v2 = _vec2.coordinates();
    // Векторное произведение v1 × v2
    final A = v1[1] * v2[2] - v1[2] * v2[1];
    final B = v1[2] * v2[0] - v1[0] * v2[2];
    final C = v1[0] * v2[1] - v1[1] * v2[0];
    final O = _O.coordinates();
    final D = -(A * O[0] + B * O[1] + C * O[2]);

    return [A, B, C, D];
  }
}

double? scalarProduct(Point vec1, Point vec2){

  if(vec1.coordinates().length != vec2.coordinates().length) return null;  
  
  double result = 0;

  for(int i = 0; i < vec1.coordinates().length; ++i){
    result += vec1.coordinates()[i]* vec2.coordinates()[i]; 
  }

  return result;
}