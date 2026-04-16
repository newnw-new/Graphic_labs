import 'dart:math' show Point;

List<Point<int>> bresenham(int x0, int y0, int x1, int y1) {
  final points = <Point<int>>[];

  int dx = (x1 - x0).abs();
  int dy = (y1 - y0).abs();

  int stepX = x0 < x1 ? 1 : -1;
  int stepY = y0 < y1 ? 1 : -1;

  int x = x0;
  int y = y0;

  if (dx > dy) {
    int d = 2 * dy - dx;
    int inc1 = 2 * dy;
    int inc2 = 2 * (dy - dx);

    for (int i = 0; i <= dx; i++) {
      points.add(Point(x, y));
      if (d < 0) {
        d += inc1;
      } else {
        y += stepY;
        d += inc2;
      }
      x += stepX;
    }
  } else {
    int d = 2 * dx - dy;
    int inc1 = 2 * dx;
    int inc2 = 2 * (dx - dy);

    for (int i = 0; i <= dy; i++) {
      points.add(Point(x, y));
      if (d < 0) {
        d += inc1;
      } else {
        x += stepX;
        d += inc2;
      }
      y += stepY;
    }
  }

  return points;
}
