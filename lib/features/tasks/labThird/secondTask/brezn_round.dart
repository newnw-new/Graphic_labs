import 'dart:math' show Point;

List<Point<int>> bresenhamRound(int xc, int yc, int radius) {
  final points = <Point<int>>[];

  if (radius == 0) {
    points.add(Point(xc, yc));
    return points;
  }

  int x = 0;
  int y = radius;

  int d = 5 - 4 * radius;

  void drawSymmetricPoints(int cx, int cy, int x, int y) {
    points.add(Point(cx + x, cy + y));
    points.add(Point(cx - x, cy + y));
    points.add(Point(cx + x, cy - y));
    points.add(Point(cx - x, cy - y));
    points.add(Point(cx + y, cy + x));
    points.add(Point(cx - y, cy + x));
    points.add(Point(cx + y, cy - x));
    points.add(Point(cx - y, cy - x));
  }

  while (x <= y) {
    drawSymmetricPoints(xc, yc, x, y);
    if (d < 0) {

      d += 8 * x + 12;
    } else {

      d += 8 * (x - y) + 20;
      y--;
    }
    x++;
  }

  return points;
}