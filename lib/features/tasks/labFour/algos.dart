List<double>? SutherlandCohen(
  double x1, double y1, double x2, double y2,
  double xmin, double xmax, double ymin, double ymax,
) {
  // Код точки: биты [left, right, bottom, top] (см. описание)
  int computeCode(double x, double y) {
    int code = 0;
    if (x < xmin) code |= 1;      // левее
    if (x > xmax) code |= 2;      // правее
    if (y < ymin) code |= 4;      // ниже
    if (y > ymax) code |= 8;      // выше
    return code;
  }

  int code1 = computeCode(x1, y1);
  int code2 = computeCode(x2, y2);

  while (true) {
    if ((code1 | code2) == 0) {
      // Тривиально внутри — отрезок видим целиком
      return [x1, y1, x2, y2];
    }
    if ((code1 & code2) != 0) {
      // Тривиально снаружи — отрезок невидим
      return null;
    }

    // Частично видим — нужно найти пересечение с границей
    int codeOut = code1 != 0 ? code1 : code2;
    double x = 0, y = 0;

    // Вычисляем пересечение с выбранной границей
    if ((codeOut & 1) != 0) {
      // Левая граница: x = xmin
      y = y1 + (y2 - y1) * (xmin - x1) / (x2 - x1);
      x = xmin;
    } else if ((codeOut & 2) != 0) {
      // Правая граница: x = xmax
      y = y1 + (y2 - y1) * (xmax - x1) / (x2 - x1);
      x = xmax;
    } else if ((codeOut & 4) != 0) {
      // Нижняя граница: y = ymin
      x = x1 + (x2 - x1) * (ymin - y1) / (y2 - y1);
      y = ymin;
    } else if ((codeOut & 8) != 0) {
      // Верхняя граница: y = ymax
      x = x1 + (x2 - x1) * (ymax - y1) / (y2 - y1);
      y = ymax;
    }

    // Заменяем точку с ненулевым кодом на найденное пересечение
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