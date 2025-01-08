import 'dart:math';
import 'package:cornell_box/models/point.dart';
import 'package:vector_math/vector_math.dart';

class Matrix {
  Matrix(int rows, int cols, this.value);

  Matrix.unit():this(4, 4,[
    [1, 0, 0, 0],
    [0, 1, 0, 0],
    [0, 0, 1, 0],
    [0, 0, 0, 1]
  ]);


  Matrix.view(Point3D eye, Point3D target, Point3D up) : value = []{
    Point3D forward = (eye - target).normalized();
    Point3D right = (up.cross(forward)).normalized();
    Point3D u = forward.cross(right);
    value.addAll([
      [right.x, u.x, forward.x, 0],
      [right.y, u.y, forward.y, 0],
      [right.z, u.z, forward.z, 0],
      [-right.dot(eye), -u.dot(eye), -forward.dot(eye), 1]
    ]);
  }

  Matrix.cameraPerspective(double fov, double aspect, double near, double far) : value = []{
    value.addAll([
      [1.0 / tan(radians(fov) / 2.0) / aspect, 0, 0, 0],
      [0, 1.0 / tan(radians(fov) / 2.0), 0, 0],
      [0, 0, (far + near) / (near - far), 1],
      [0, 0, (2 * far * near) / (near - far), 0]
    ]);
  }
  
  Matrix.point(Point3D point) : this(1, 4, [[point.x, point.y, point.z, 1]]);

  Matrix.translation(Point3D tr)
    : this(4, 4,
    [
      [1, 0, 0, 0],
      [0, 1, 0, 0],
      [0, 0, 1, 0],
      [tr.x, tr.y, tr.z, 1],
    ]
  );

  Matrix.scaling(Point3D sc)
      : this(4, 4,
      [
        [sc.x, 0, 0, 0],
        [0, sc.y, 0, 0],
        [0, 0, sc.z, 0],
        [0, 0, 0, 1],
      ]
  );

  Matrix.rotation(double a, Point3D v)
    : this(4, 4,
    [
      [v.x * v.x + cos(a) * (1 - v.x * v.x), v.x * (1 - cos(a)) * v.y + v.z * sin(a), v.x * (1 - cos(a)) * v.z - v.y * sin(a), 0],
      [v.x * (1 - cos(a)) * v.y - v.z * sin(a), v.y * v.y + cos(a) * (1 - v.y * v.y), v.y * (1 - cos(a)) * v.z + v.x * sin(a), 0],
      [v.x * (1 - cos(a)) * v.z + v.y * sin(a), v.y * (1 - cos(a)) * v.z - v.x * sin(a), v.z * v.z + cos(a) * (1 - v.z * v.z), 0],
      [0, 0, 0, 1]
    ]
  );
  
  final List<List<double>> value;

  int get rows => value.length;

  int get cols => value[0].length;

  List<double> operator [](int index) {
    return value[index];
  }

  Matrix operator *(Matrix other) {
    final newValue = List.filled(rows, List.filled(other.cols, 0.0));
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < other.cols; j++) {
        for (int k = 0; k < cols; k++) {
          newValue[i][j] += this[i][k] * other[k][j];
        }
      }
    }
    return Matrix(rows, other.cols, newValue);
  }
}
