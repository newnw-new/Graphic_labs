
class Point {
  // Нужно будет переделать его под произвольное количество координат
  //хотя для моих нужд наверно будет достаточно 3-х
  final double x;
  final double y;

  const Point({required this.x, required this.y});
}

class LineEquation {
  late double A;
  late double B;
  late double C;

  LineEquation({required this.A, required this.B, required this.C});
  LineEquation.withTwoPoints({required Point A1, required Point A2})
  {
    A = A2.y - A1.y;
    B = A1.x - A2.x;
    C = A1.y*A2.x - A1.x*A2.y;
  }
  LineEquation.withPointAndVector({required Point O, required Point vec}){
    A = vec.y;
    B = -vec.x;
    C = O.y*vec.x- O.x*vec.y;
  }

  String getStringFormat(){
    return '${A}x+${B}y+${C} = 0';
  }
  
}