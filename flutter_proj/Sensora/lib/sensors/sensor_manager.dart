import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

class SensorManager {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;

  Function(AccelerometerEvent)? onAccelerometer;
  Function(GyroscopeEvent)? onGyroscope;
  Function(MagnetometerEvent)? onMagnetometer;

  void startSensors() {
    _accelerometerSubscription =
        accelerometerEventStream().listen((event) {
          onAccelerometer?.call(event);
        });

    _gyroscopeSubscription =
        gyroscopeEventStream().listen((event) {
          onGyroscope?.call(event);
        });

    _magnetometerSubscription =
        magnetometerEventStream().listen((event) {
          onMagnetometer?.call(event);
        });
  }

  void stopSensors() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _magnetometerSubscription?.cancel();
  }
}