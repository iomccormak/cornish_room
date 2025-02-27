import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cornell_box/models/camera.dart';
import 'package:cornell_box/models/intersection.dart';
import 'package:cornell_box/models/light.dart';
import 'package:cornell_box/models/matrix.dart';
import 'package:cornell_box/models/point.dart';
import 'package:cornell_box/models/model.dart';
import 'package:cornell_box/models/ray.dart';
import 'package:cornell_box/models/sphere.dart';
import 'package:meta/meta.dart';
import 'package:cornell_box/models/interfaces.dart' as graphics;
import 'package:vector_math/vector_math.dart' as vm;

part 'main_event.dart';

part 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit() : super(const LoadingState());

  List<graphics.Object> scene = [];

  Camera camera = Camera(
    eye: Point3D(0, 0, 3.3),
    target: Point3D(0, 0, 0),
    up: Point3D(0, -1, 0),
  );

  final List<Light> lights = [
    Light(
      position: Point3D(0, 0.96, 1.4),
      width: 1.0,
      height: 0.5,
      step: 0.03,
      color: Point3D(0.7, 0.7, 0.7),
    ),
  ];

  final ambientLight = Point3D(0.05, 0.05, 0.05);
  int width = 0;
  int height = 0;
  final Map<String, List<List<({Color color, Offset pos})?>>> _pixels = {};
  Matrix _view = Matrix.unit();
  Matrix _projection = Matrix.unit();
  static const pixelRatio = 100;

  void _buildScene(String configuration) {
    scene = [
      Model.cube(
        specularStrength: 0.5,
        color: Colors.orange,
        reflectivity: configuration[2] == '1' ? 0.85 : 0.0,
      )
          .getTransformed(Matrix.rotation(vm.radians(-40), Point3D(0, 1, 0)))
          .getTransformed(Matrix.scaling(Point3D(0.5, 0.5, 0.5)))
          .getTransformed(Matrix.translation(Point3D(0.6, -1, 0.8))),
      Model.cube(
        specularStrength: 0.5,
        color: Colors.purple,
        transparency: configuration[4] == '1' ? 0.95 : 0.0,
      )
          .getTransformed(Matrix.rotation(vm.radians(30), Point3D(0, 1, 0)))
          .getTransformed(Matrix.scaling(Point3D(0.5, 0.5, 0.5)))
          .getTransformed(Matrix.translation(Point3D(-0.4, -1, 0.4))),
      Sphere(
        reflectivity: configuration[1] == '1' ? 0.85 : 0.0,
        color: Colors.green,
        radius: 0.3,
        transparency: 0.0,
        center: Point3D(0.0, 0.5, 0.6),
        specularStrength: 0.4,
        shininess: 8,
      ),
      Sphere(
        reflectivity: 0.0,
        color: Colors.yellow,
        radius: 0.3,
        transparency: configuration[3] == '1' ? 0.95 : 0.0,
        center: Point3D(-0.8, -0.7, 0.6),
        specularStrength: 0.4,
        shininess: 8,
      ),
      // left
      Model(
        specularStrength: 0.0,
        reflectivity: configuration[0] == '2' ? 0.85 : 0.0,
        color: Colors.red,
        points: [
          Point3D(-1.2, 1, 0),
          Point3D(-1.2, -1, 0),
          Point3D(-1.2, -1, 5),
          Point3D(-1.2, 1, 5)
        ],
        polygonsByIndexes: [
          [0, 1, 2],
          [2, 3, 0]
        ],
      ),
      // bottom
      Model(
        specularStrength: 0.0,
        reflectivity: configuration[0] == '3' ? 0.85 : 0.0,
        color: Colors.grey,
        points: [
          Point3D(-1.2, -1, 0),
          Point3D(1.2, -1, 0),
          Point3D(-1.2, -1, 5),
          Point3D(1.2, -1, 5)
        ],
        polygonsByIndexes: [
          [0, 1, 2],
          [1, 3, 2]
        ],
      ),
      // right
      Model(
        specularStrength: 0.0,
        reflectivity: configuration[0] == '4' ? 0.85 : 0.0,
        color: Colors.blue,
        points: [
          Point3D(1.2, -1, 0),
          Point3D(1.2, 1, 0),
          Point3D(1.2, -1, 5),
          Point3D(1.2, 1, 5)
        ],
        polygonsByIndexes: [
          [0, 1, 2],
          [2, 1, 3]
        ],
      ),
      // top
      Model(
        specularStrength: 0.0,
        reflectivity: configuration[0] == '5' ? 0.85 : 0.0,
        color: Colors.green,
        points: [
          Point3D(1.2, 1, 0),
          Point3D(-1.2, 1, 5),
          Point3D(1.2, 1, 5),
          Point3D(-1.2, 1, 0)
        ],
        polygonsByIndexes: [
          [0, 1, 2],
          [0, 3, 1]
        ],
      ),
      // forward
      Model(
        specularStrength: 0.0,
        reflectivity: configuration[0] == '6' ? 0.85 : 0.0,
        color: Colors.yellow,
        points: [
          Point3D(1.2, 1, 0),
          Point3D(1.2, -1, 0),
          Point3D(-1.2, -1, 0),
          Point3D(-1.2, 1, 0)
        ],
        polygonsByIndexes: [
          [0, 1, 2],
          [2, 3, 0]
        ],
      ),
    ];
  }

  void render(String configuration, Light? secondLight) async {
    emit(const LoadingState());

    _view = Matrix.view(
      camera.eye,
      camera.target,
      camera.up,
    );

    _projection = Matrix.cameraPerspective(
      camera.fov,
      width / height,
      camera.nearPlane,
      camera.farPlane,
    );

    if (secondLight != null) {
      lights.add(secondLight);
    }

    _pixels[configuration] = List.generate(
      height,
      (_) => List.filled(width, null),
    );
    _buildScene(configuration);

    for (var pixelRay in camera.getRays(width, height)) {
      final pixel = pixelRay.pixel;
      Point3D color = Point3D(0, 0, 0);
      int numSamples = 0;
      Point3D? rayColor;

      for (var ray in pixelRay.rays) {
        rayColor = _traceRay(ray, 7);
        if (rayColor != null) {
          numSamples++;
          color += rayColor;
        }
      }

      if (numSamples > 0) {
        final resColor = Color.fromRGBO(
          color.x * 255 ~/ numSamples,
          color.y * 255 ~/ numSamples,
          color.z * 255 ~/ numSamples,
          1.0,
        );
        _pixels[configuration]![pixel.dy.toInt()][pixel.dx.toInt()] =
            (color: resColor, pos: pixel);
      }
    }

    emit(CommonState(pixels: _pixels[configuration]!));
    if (secondLight != null) {
      lights.removeLast();
    }
  }

  Point3D? _traceRay(Ray ray, int depth) {
    if (depth <= 0) {
      return Point3D(0, 0, 0);
    }

    graphics.Object? intersectionObject;
    Intersection? nearestIntersection;

    for (var object in scene) {
      var intersection = object.intersect(
        camera: camera,
        projection: _projection,
        view: _view,
        ray: ray,
      );

      if (intersection == null) {
        continue;
      }

      if (nearestIntersection == null ||
          intersection.z < nearestIntersection.z) {
        nearestIntersection = intersection;
        intersectionObject = object;
      }
    }

    if (nearestIntersection != null) {
      // преломление
      if (intersectionObject!.transparency > 0.1) {
        Point3D light = Point3D.zero();

        Ray? refractedRay = _refract(
          ray,
          nearestIntersection,
          intersectionObject.refractiveIndex,
        );

        if (refractedRay != null) {
          light += (_traceRay(refractedRay, depth - 1) ?? Point3D(0, 0, 0)) *
              intersectionObject.transparency;
        }
        return light;
      }

      // отражение
      if (intersectionObject.reflectivity > 0.1) {
        Point3D reflectedRayDirection = _reflect(
          ray.direction,
          nearestIntersection.normal,
        );

        Ray reflectedRay = Ray(
          start: nearestIntersection.hit + reflectedRayDirection * 0.001,
          direction: reflectedRayDirection,
        );

        Point3D reflectedColor =
            _traceRay(reflectedRay, depth - 1) ?? Point3D(0, 0, 0);
        return reflectedColor * intersectionObject.reflectivity;
      }

      Point3D light = _calcLocalLight(nearestIntersection, intersectionObject);
      return light.multiply(intersectionObject.objectColor);
    }

    return null;
  }

  Point3D _reflect(Point3D vector, Point3D normal) {
    return vector - normal * 2 * vector.dot(normal);
  }

  Ray? _refract(
    Ray incidentRay,
    Intersection intersection,
    double refractiveIndex,
  ) {
    double ratio = intersection.inside ? refractiveIndex : 1 / refractiveIndex;
    final incident = incidentRay.direction.normalized();
    final normal =
        intersection.inside ? -intersection.normal : intersection.normal;

    double cosi = normal.dot(incident);
    double k = 1 - ratio * ratio * (1 - cosi * cosi);

    if (k < 0) {
      return null;
    } else {
      final refracted = incident * ratio - normal * (sqrt(k) + ratio * cosi);

      return Ray(
        start: intersection.hit + refracted * 0.001,
        direction: refracted,
      );
    }
  }

  Point3D _calcLocalLight(Intersection intersection, graphics.Object object) {
    Point3D color = Point3D.zero();
    for (var light in lights) {
      double illuminationRatio;
      Point3D lightDir = (intersection.hit - light.position).normalized();
      bool inShadow = false;
      for (var object in scene) {
        final shadowRay = Ray(
          start: intersection.hit - lightDir * 0.001,
          direction: -lightDir,
        );

        final shadowIntersection = object.intersect(
          ray: shadowRay,
          view: _view,
          projection: _projection,
          camera: camera,
        );

        if (shadowIntersection != null &&
            (intersection.hit - light.position).length() >
                (intersection.hit - shadowIntersection.hit).length()) {
          inShadow = true;
          break;
        }
      }
      if (!inShadow) {
        illuminationRatio = 1.0;
      } else {
        illuminationRatio = 0.15;
      }
      if (illuminationRatio > 1e-2) {
        Point3D lightDir = (intersection.hit - light.position).normalized();

        // diffuse
        double diff = max(intersection.normal.dot(-lightDir), 0.0);
        color += light.color * diff * illuminationRatio;

        // specular
        if (object.transparency < 0.1 && object.reflectivity < 0.1) {
          Point3D viewDir = (camera.eye - intersection.hit).normalized();
          Point3D reflectedDir = _reflect(lightDir, intersection.normal);
          double spec =
              pow(max(viewDir.dot(reflectedDir), 0.0), object.shininess)
                  .toDouble();
          color +=
              light.color * object.specularStrength * spec * illuminationRatio;
        }
      }
    }
    //ambient
    color += ambientLight;
    return color..limitTop(1.0);
  }

  static Offset point3DToOffset(Point3D point3d, Size size) {
    return Offset((point3d.x / point3d.h + 1.0) * 0.5 * size.width,
        (1.0 - point3d.y / point3d.h) * 0.5 * size.height);
  }

  static Point3D offsetToPoint3D(Offset offset, Size size) {
    return Point3D((offset.dx - size.width / 2) / pixelRatio,
        -(offset.dy - size.height / 2) / pixelRatio, 0);
  }
}
