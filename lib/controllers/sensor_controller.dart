import 'dart:async';
import 'dart:math' as math;
import 'package:get/get.dart';

import '../models/sensor_data.dart';
import '../sensors/sensor_manager.dart';

class SensorController extends GetxController {
  final SensorManager sensorManager = SensorManager();

  double _latestAzimuth = 0.0;
  double _latestPitch = 0.0;
  double _latestRoll = 0.0;


  final RxDouble tiltX = 0.0.obs;
  final RxDouble tiltY = 0.0.obs;
  final RxDouble azimuth = 0.0.obs;
  final RxDouble pitch = 0.0.obs;
  final RxDouble roll = 0.0.obs;

  final Rx<SensorData> accelerometer = SensorData(
    x: 0,
    y: 0,
    z: 0,
    timestamp: DateTime.now(),
  ).obs;

  final Rx<SensorData> gyroscope = SensorData(
    x: 0,
    y: 0,
    z: 0,
    timestamp: DateTime.now(),
  ).obs;

  final Rx<SensorData> magnetometer = SensorData(
    x: 0,
    y: 0,
    z: 0,
    timestamp: DateTime.now(),
  ).obs;

  final RxList<SensorData> accelerometerHistory =
      <SensorData>[].obs;

  final RxList<SensorData> gyroscopeHistory =
      <SensorData>[].obs;

  final RxList<SensorData> magnetometerHistory =
      <SensorData>[].obs;

  static const int maxHistoryLength = 50;

  SensorData? _latestAccelerometer;
  SensorData? _latestGyroscope;
  SensorData? _latestMagnetometer;
  Timer? _uiTimer;

  // UI updates every 200 ms = 5 FPS
  static const Duration uiUpdateInterval =
  Duration(milliseconds: 200);
  @override
  void onInit() {
    super.onInit();

    sensorManager.onOrientation = (event) {
      _latestAzimuth = event.eulerAngles.azimuth;
      _latestPitch = event.eulerAngles.pitch;
      _latestRoll = event.eulerAngles.roll;
    };

    sensorManager.onAccelerometer = (event) {
      _latestAccelerometer = SensorData(
        x: event.x,
        y: event.y,
        z: event.z,
        timestamp: DateTime.now(),
      );
    };

    sensorManager.onGyroscope = (event) {
      _latestGyroscope = SensorData(
        x: event.x,
        y: event.y,
        z: event.z,
        timestamp: DateTime.now(),
      );
    };


    sensorManager.onMagnetometer = (event) {
      _latestMagnetometer = SensorData(
        x: event.x,
        y: event.y,
        z: event.z,
        timestamp: DateTime.now(),
      );
    };

    // Start sensors
    sensorManager.startSensors();

    // Start controlled UI updates
    _startUiTimer();
  }

  void _startUiTimer() {
    _uiTimer = Timer.periodic(
      uiUpdateInterval,
          (_) {
        _updateUI();
      },
    );
  }

  void _updateUI() {

    azimuth.value = _latestAzimuth;
    pitch.value = _latestPitch;
    roll.value = _latestRoll;

    if (_latestAccelerometer != null) {
      accelerometer.value = _latestAccelerometer!;

      accelerometerHistory.add(
        _latestAccelerometer!,
      );

      if (accelerometerHistory.length > maxHistoryLength) {
        accelerometerHistory.removeAt(0);
      }

      final x = _latestAccelerometer!.x;
      final y = _latestAccelerometer!.y;
      final z = _latestAccelerometer!.z;

      tiltX.value =
          math.atan2(
            x,
            math.sqrt(y * y + z * z),
          ) *
              180 /
              math.pi;

      tiltY.value =
          math.atan2(
            y,
            math.sqrt(x * x + z * z),
          ) *
              180 /
              math.pi;
    }

    if (_latestGyroscope != null) {
      gyroscope.value = _latestGyroscope!;

      gyroscopeHistory.add(
        _latestGyroscope!,
      );

      if (gyroscopeHistory.length > maxHistoryLength) {
        gyroscopeHistory.removeAt(0);
      }
    }

    if (_latestMagnetometer != null) {
      magnetometer.value = _latestMagnetometer!;

      magnetometerHistory.add(
        _latestMagnetometer!,
      );

      if (magnetometerHistory.length > maxHistoryLength) {
        magnetometerHistory.removeAt(0);
      }
    }
  }

  @override
  void onClose() {
    _uiTimer?.cancel();
    sensorManager.stopSensors();

    super.onClose();
  }
}