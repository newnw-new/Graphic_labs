
class Point {
  // Нужно будет переделать его под произвольное количество координат
  //хотя для моих нужд наверно будет достаточно 3-х
  final int x;
  final int y;

  const Point({required this.x, required this.y});
}

class LineEquation {
  late int A;
  late int B;
  late int C;

  LineEquation({required this.A, required this.B, required this.C});
  LineEquation.withTwoPoints({required Point A1, required Point A2})
  {
    A = A2.y - A1.y;
    B = A1.x - A2.x;
    C = A1.y*A2.x - A1.x*A2.y;
  }

  String getStringFormat(){
    return '${A}x+${B}y+${C} = 0';
  }
  
}