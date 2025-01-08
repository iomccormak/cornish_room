import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cornell_box/models/camera.dart';
import 'package:cornell_box/models/intersection.dart';
import 'package:cornell_box/models/interfaces.dart';
import 'package:cornell_box/models/matrix.dart';
import 'package:cornell_box/models/point.dart';
import 'package:cornell_box/models/polygon.dart';
import 'package:cornell_box/models/ray.dart';

class Model implements IPoints, Object {
  final List<Polygon> polygons;
  @override
  final List<Point3D> points;
  final List<List<int>> polygonsByIndexes;
  final Color color;
  @override
  final double specularStrength;
  @override
  final double shininess;
  @override
  final double reflectivity;
  @override
  final double transparency;
  @override
  final double refractiveIndex;

  Model(
      {required this.points,
      required this.polygonsByIndexes,
      required this.color,
      this.shininess = 8,
      this.specularStrength = 0.5,
      this.reflectivity = 0.0,
      this.transparency = 0.0,
      this.refractiveIndex = 1.05})
      : polygons = [] {
    for (var polygonIndexes in polygonsByIndexes) {
      polygons.add(Polygon(List.generate(
          polygonIndexes.length, (i) => points[polygonIndexes[i]])));
    }
  }

  @override
  Point3D get objectColor =>
      Point3D(color.red / 255, color.green / 255, color.blue / 255, 1.0);

  @override
  Intersection? intersect(
      {required Ray ray,
      required Camera camera,
      required Matrix view,
      required Matrix projection}) {
    Intersection? nearestRes;
    double nearestZ = double.infinity;
    for (var polygon in polygons) {
      var res = polygon.intersect(ray);
      if (res == null) {
        continue;
      }

      final z = (res - ray.start).length();
      if (z < nearestZ) {
        nearestZ = z;
        nearestRes = Intersection(
            inside: ray.direction.dot(-polygon.normal) > 0,
            normal: -polygon.normal,
            hit: res,
            z: z);
      }
    }
    return nearestRes;
  }

  Point3D get center {
    var sum = Point3D.zero();
    for (var point in points) {
      sum = sum + point;
    }
    return sum / points.length;
  }

  Model getTransformed(Matrix transform) {
    final res = copy();
    for (var point in res.points) {
      point.updateWithVector(Matrix.point(point) * transform);
    }
    return res;
  }

  Model copy() {
    return Model(
        reflectivity: reflectivity,
        shininess: shininess,
        specularStrength: specularStrength,
        color: color,
        transparency: transparency,
        refractiveIndex: refractiveIndex,
        points: List.generate(points.length, (index) => points[index].copy()),
        polygonsByIndexes: polygonsByIndexes);
  }

  Model concat(Model other) {
    List<Point3D> resPoints = [];
    List<List<int>> resIndexes = [];

    for (var p in points) {
      resPoints.add(p.copy());
    }
    for (var p in other.points) {
      resPoints.add(p.copy());
    }

    for (var pol in polygonsByIndexes) {
      resIndexes.add(List.from(pol));
    }
    int len = points.length;
    for (var pol in other.polygonsByIndexes) {
      resIndexes.add(pol.map((e) => e + len).toList());
    }

    return Model(
        color: color, points: resPoints, polygonsByIndexes: resIndexes);
  }

  Model.cube({
    required Color color,
    double specularStrength = 0.0,
    double shininess = 8,
    double reflectivity = 0.0,
    double transparency = 0.0,
  }) : this(
            reflectivity: reflectivity,
            transparency: transparency,
            specularStrength: specularStrength,
            shininess: shininess,
            points: [
              Point3D(1, 0, 0),
              Point3D(1, 1, 0),
              Point3D(0, 1, 0),
              Point3D(0, 0, 0),
              Point3D(0, 0, 1),
              Point3D(0, 1, 1),
              Point3D(1, 1, 1),
              Point3D(1, 0, 1),
            ],
            color: color,
            polygonsByIndexes: [
              [0, 1, 2],
              [2, 3, 0],
              [5, 2, 1],
              [1, 6, 5],
              [4, 5, 6],
              [6, 7, 4],
              [3, 4, 7],
              [7, 0, 3],
              [7, 6, 1],
              [1, 0, 7],
              [3, 2, 5],
              [5, 4, 3],
            ]);
}
