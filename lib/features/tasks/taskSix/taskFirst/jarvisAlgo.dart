// Вспомогательная функция: косое произведение векторов oa и ob
// Возвращает >0 если b слева от o->a, <0 если справа, 0 если коллинеарны
import 'package:graphic/core/utils/Geomerty.dart';

num cross(Point o, Point a, Point b) {
  return (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x);
}

num dist(Point a, Point b) {
  final dx = a.x - b.x;
  final dy = a.y - b.y;
  return dx * dx + dy * dy;
}

List<Point> jarvis(List<Point> points) {
  final n = points.length;
  if (n <= 3) return List.from(points);

  Point start = points[0];
  for (final p in points) {
    if (p.y < start.y || (p.y == start.y && p.x < start.x)) {
      start = p;
    }
  }

  final hull = <Point>[];
  Point current = start;

  while (true) {
    hull.add(current);

    Point? next;
    for (final p in points) {
      if (p == current) continue;
      if (next == null) {
        next = p;
        continue;
      }
      final cr = cross(current, next, p);
      if (cr < 0) {
        next = p;
      } else if (cr == 0) {
        if (dist(current, p) > dist(current, next)) {
          next = p;
        }
      }
    }

    if (next == start) break;

    current = next!;
  }

  return hull;
}