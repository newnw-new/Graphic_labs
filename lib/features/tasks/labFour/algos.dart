import 'package:graphic/core/utils/Geomerty.dart';

List<double>? SutherlandCohen(
  double x1, double y1, double x2, double y2,
  double xmin, double xmax, double ymin, double ymax,
) {
  int computeCode(double x, double y) {
    int code = 0;
    if (x < xmin) code |= 1;
    if (x > xmax) code |= 2;
    if (y < ymin) code |= 4;
    if (y > ymax) code |= 8;
    return code;
  }

  int code1 = computeCode(x1, y1);
  int code2 = computeCode(x2, y2);

  while (true) {
    if ((code1 | code2) == 0) {
      return [x1, y1, x2, y2];
    }
    if ((code1 & code2) != 0) {
      return null;
    }

    int codeOut = code1 != 0 ? code1 : code2;
    double x = 0, y = 0;

    if ((codeOut & 1) != 0) {
      y = y1 + (y2 - y1) * (xmin - x1) / (x2 - x1);
      x = xmin;
    } else if ((codeOut & 2) != 0) {
      y = y1 + (y2 - y1) * (xmax - x1) / (x2 - x1);
      x = xmax;
    } else if ((codeOut & 4) != 0) {
      x = x1 + (x2 - x1) * (ymin - y1) / (y2 - y1);
      y = ymin;
    } else if ((codeOut & 8) != 0) {
      x = x1 + (x2 - x1) * (ymax - y1) / (y2 - y1);
      y = ymax;
    }

    if (codeOut == code1) {
      x1 = x;
      y1 = y;
      code1 = computeCode(x1, y1);
    } else {
      x2 = x;
      y2 = y;
      code2 = computeCode(x2, y2);
    }
  }
}

List<List<double>> midpointClip(
  double x1, double y1, double x2, double y2,
  double xmin, double xmax, double ymin, double ymax, {
  double epsilon = 0.25,
  int maxDepth = 50,
}) {
  final result = <List<double>>[];

  int computeCode(double x, double y) {
    int code = 0;
    if (x < xmin) code |= 1;
    if (x > xmax) code |= 2;
    if (y < ymin) code |= 4;
    if (y > ymax) code |= 8;
    return code;
  }

  void recurse(double x1, double y1, double x2, double y2, int depth) {
    final code1 = computeCode(x1, y1);
    final code2 = computeCode(x2, y2);

    if ((code1 | code2) == 0) {
      result.add([x1, y1, x2, y2]);
      return;
    }

    if ((code1 & code2) != 0) {
      return;
    }

    final dx = x2 - x1;
    final dy = y2 - y1;
    if ((dx.abs() < epsilon && dy.abs() < epsilon) || depth >= maxDepth) {
      if (code1 == 0 || code2 == 0) {
        result.add([x1, y1, x2, y2]);
      }
      return;
    }

    final xm = (x1 + x2) / 2;
    final ym = (y1 + y2) / 2;

    recurse(x1, y1, xm, ym, depth + 1);
    recurse(xm, ym, x2, y2, depth + 1);
  }

  recurse(x1, y1, x2, y2, 0);
  return result;
}

List<List<Vec>?> cyrusBeckClip(Vec P1, Vec P2, List<Vec> polygon) {
  final D = P2 - P1;
  double tEntry = 0.0;
  double tExit = 1.0;

  final List<Vec> entryPoints = [];
  final List<Vec> exitPoints = [];

  final int n = polygon.length;
  for (int i = 0; i < n; i++) {
    final a = polygon[i];
    final b = polygon[(i + 1) % n];
    final edgeVec = b - a;
    final dx = edgeVec.coordinates[0];
    final dy = edgeVec.coordinates[1];

    Vec normal = Vec([-dy, dx]);

    final numerator = scalarProduct(normal, a - P1)!;
    final denominator = scalarProduct(normal, D)!;

    if (denominator.abs() < 1e-9) {
      if (scalarProduct(normal, P1 - a)! > 0) {
        return [entryPoints, exitPoints, null];
      }
      continue;
    }

    final t = numerator / denominator;
    final intersectionPoint = P1 + vecMulScalar(D, t);

    if (denominator < 0) {

      entryPoints.add(intersectionPoint);
      if (t > tEntry) tEntry = t;
    } else {

      exitPoints.add(intersectionPoint);
      if (t < tExit) tExit = t;
    }
  }

  if (tEntry <= tExit) {
    final start = P1 + vecMulScalar(D, tEntry);
    final end   = P1 + vecMulScalar(D, tExit);
    return [entryPoints, exitPoints, [start, end]];
  } else {
    return [entryPoints, exitPoints, null];
  }
}