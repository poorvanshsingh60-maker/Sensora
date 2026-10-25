import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart';
import 'package:light/light.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorManager {
  // --------------------------------------------------
  // SENSOR SUBSCRIPTIONS
  // --------------------------------------------------

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;
  StreamSubscription<OrientationEvent>? _orientationSubscription;
  StreamSubscription<CompassEvent>? _compassSubscription;

  StreamSubscription<int>? _lightSubscription;
  StreamSubscription<int>? _proximitySubscription;

  double _lastAccelerationMagnitude = 0.0;
  DateTime? _lastShakeTime;

  // --------------------------------------------------
  // CALLBACKS
  // --------------------------------------------------

  Function(AccelerometerEvent)? onAccelerometer;
  Function(GyroscopeEvent)? onGyroscope;
  Function(MagnetometerEvent)? onMagnetometer;
  Function(OrientationEvent)? onOrientation;
  Function(double)? onCompass;

  Function(double)? onLight;
  Function(bool)? onProximity;
  Function()? onShake;

  // --------------------------------------------------
  // START SENSORS
  // --------------------------------------------------

  void startSensors() {
    // Accelerometer
    _accelerometerSubscription =
        accelerometerEventStream().listen((event) {
          onAccelerometer?.call(event);

          final magnitude = math.sqrt(
            event.x * event.x +
                event.y * event.y +
                event.z * event.z,
          );

          final change =
          (magnitude - _lastAccelerationMagnitude).abs();

          _lastAccelerationMagnitude = magnitude;

          final now = DateTime.now();

          // Prevent multiple shake detections from one shake
          final canDetectShake =
              _lastShakeTime == null ||
                  now.difference(_lastShakeTime!).inMilliseconds > 700;

          if (change > 7.0 && canDetectShake) {
            _lastShakeTime = now;
            onShake?.call();
          }
        });

    // Gyroscope
    _gyroscopeSubscription =
        gyroscopeEventStream().listen((event) {
          onGyroscope?.call(event);
        });

    // Magnetometer
    _magnetometerSubscription =
        magnetometerEventStream().listen((event) {
          onMagnetometer?.call(event);
        });

    // Rotation / Orientation
    _orientationSubscription =
        RotationSensor.orientationStream.listen((event) {
          onOrientation?.call(event);
        });

    // Compass
    _compassSubscription =
        FlutterCompass.events?.listen((event) {

          final heading = event.heading;

          if (heading != null) {
            onCompass?.call(heading);
          }
        });

    // Light
    _lightSubscription =
        Light().lightSensorStream.listen((lux) {
          onLight?.call(lux.toDouble());
        });

    // Proximity
    try {
      _proximitySubscription =
          ProximitySensor.events.listen((event) {
            onProximity?.call(event > 0);
          });
    } catch (e) {
      // Proximity sensor unavailable
    }
  }

  // --------------------------------------------------
  // STOP SENSORS
  // --------------------------------------------------

  void stopSensors() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _magnetometerSubscription?.cancel();
    _orientationSubscription?.cancel();
    _compassSubscription?.cancel();

    _lightSubscription?.cancel();
    _proximitySubscription?.cancel();
  }
}