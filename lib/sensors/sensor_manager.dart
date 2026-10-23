import 'dart:async';

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

  StreamSubscription<int>? _lightSubscription;
  StreamSubscription<int>? _proximitySubscription;

  // --------------------------------------------------
  // CALLBACKS
  // --------------------------------------------------

  Function(AccelerometerEvent)? onAccelerometer;
  Function(GyroscopeEvent)? onGyroscope;
  Function(MagnetometerEvent)? onMagnetometer;
  Function(OrientationEvent)? onOrientation;

  Function(double)? onLight;
  Function(bool)? onProximity;

  // --------------------------------------------------
  // START SENSORS
  // --------------------------------------------------

  void startSensors() {
    // Accelerometer
    _accelerometerSubscription =
        accelerometerEventStream().listen((event) {
          onAccelerometer?.call(event);
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

    // Light
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

    _lightSubscription?.cancel();
    _proximitySubscription?.cancel();
  }
}