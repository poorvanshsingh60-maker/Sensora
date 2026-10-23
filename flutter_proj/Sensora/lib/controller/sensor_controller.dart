import 'dart:async';

import 'package:get/get.dart';

import '../models/sensor_data.dart';
import '../sensors/sensor_manager.dart';

class SensorController extends GetxController {
  final SensorManager sensorManager = SensorManager();

  // --------------------------------------------------
  // ROTATION / ORIENTATION
  // --------------------------------------------------

  double _latestAzimuth = 0.0;
  double _latestPitch = 0.0;
  double _latestRoll = 0.0;

  final RxDouble azimuth = 0.0.obs;
  final RxDouble pitch = 0.0.obs;
  final RxDouble roll = 0.0.obs;

  // --------------------------------------------------
  // CURRENT VALUES SHOWN IN UI
  // --------------------------------------------------

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

  // --------------------------------------------------
  // GRAPH HISTORY
  // --------------------------------------------------

  final RxList<SensorData> accelerometerHistory =
      <SensorData>[].obs;

  final RxList<SensorData> gyroscopeHistory =
      <SensorData>[].obs;

  final RxList<SensorData> magnetometerHistory =
      <SensorData>[].obs;

  static const int maxHistoryLength = 50;

  // --------------------------------------------------
  // LATEST RAW VALUES
  // --------------------------------------------------

  SensorData? _latestAccelerometer;
  SensorData? _latestGyroscope;
  SensorData? _latestMagnetometer;

  // --------------------------------------------------
  // UI UPDATE TIMER
  // --------------------------------------------------

  Timer? _uiTimer;

  // UI updates every 200 ms = 5 FPS
  static const Duration uiUpdateInterval =
  Duration(milliseconds: 200);

  // --------------------------------------------------
  // INITIALIZATION
  // --------------------------------------------------

  @override
  void onInit() {
    super.onInit();

    // --------------------------------------------------
    // ROTATION / ORIENTATION
    // --------------------------------------------------

    sensorManager.onOrientation = (event) {
      _latestAzimuth = event.eulerAngles.azimuth;
      _latestPitch = event.eulerAngles.pitch;
      _latestRoll = event.eulerAngles.roll;
    };

    // --------------------------------------------------
    // ACCELEROMETER
    // --------------------------------------------------

    sensorManager.onAccelerometer = (event) {
      _latestAccelerometer = SensorData(
        x: event.x,
        y: event.y,
        z: event.z,
        timestamp: DateTime.now(),
      );
    };

    // --------------------------------------------------
    // GYROSCOPE
    // --------------------------------------------------

    sensorManager.onGyroscope = (event) {
      _latestGyroscope = SensorData(
        x: event.x,
        y: event.y,
        z: event.z,
        timestamp: DateTime.now(),
      );
    };

    // --------------------------------------------------
    // MAGNETOMETER
    // --------------------------------------------------

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

  // --------------------------------------------------
  // UI TIMER
  // --------------------------------------------------

  void _startUiTimer() {
    _uiTimer = Timer.periodic(
      uiUpdateInterval,
          (_) {
        _updateUI();
      },
    );
  }

  // --------------------------------------------------
  // UPDATE UI
  // --------------------------------------------------

  void _updateUI() {
    // --------------------------------------------------
    // ROTATION
    // --------------------------------------------------

    azimuth.value = _latestAzimuth;
    pitch.value = _latestPitch;
    roll.value = _latestRoll;

    // --------------------------------------------------
    // ACCELEROMETER
    // --------------------------------------------------

    if (_latestAccelerometer != null) {
      accelerometer.value = _latestAccelerometer!;

      accelerometerHistory.add(
        _latestAccelerometer!,
      );

      if (accelerometerHistory.length > maxHistoryLength) {
        accelerometerHistory.removeAt(0);
      }
    }

    // --------------------------------------------------
    // GYROSCOPE
    // --------------------------------------------------

    if (_latestGyroscope != null) {
      gyroscope.value = _latestGyroscope!;

      gyroscopeHistory.add(
        _latestGyroscope!,
      );

      if (gyroscopeHistory.length > maxHistoryLength) {
        gyroscopeHistory.removeAt(0);
      }
    }

    // --------------------------------------------------
    // MAGNETOMETER
    // --------------------------------------------------

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

  // --------------------------------------------------
  // CLEANUP
  // --------------------------------------------------

  @override
  void onClose() {
    _uiTimer?.cancel();
    sensorManager.stopSensors();

    super.onClose();
  }
}