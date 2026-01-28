import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OrientationService {
  static double rotationFromDevice(DeviceOrientation orientation) {
    switch (orientation) {
      case DeviceOrientation.landscapeLeft:
        return pi / 2;
      case DeviceOrientation.landscapeRight:
        return -pi / 2;
      case DeviceOrientation.portraitDown:
        return pi;
      case DeviceOrientation.portraitUp:
      default:
        return 0.0;
    }
  }

  /// Wraps a widget in rotation based on current rotation angle
  static Widget rotateUI(double angle, Widget child) {
    return Transform.rotate(
      angle: angle,
      child: child,
    );
  }
}
