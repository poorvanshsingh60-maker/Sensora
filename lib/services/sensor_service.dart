import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class FullSensorTelemetry {
  // Calibrated & Filtered Accelerometer (m/s^2)
  final double accX, accY, accZ;
  // Gravity-Compensated True Linear Acceleration (m/s^2)
  final double linAccX, linAccY, linAccZ;
  // Calibrated & Filtered Gyroscope (rad/s)
  final double gyroX, gyroY, gyroZ;
  // Hard & Soft-Iron Calibrated Magnetometer (uT) & Tilt-Compensated Heading (Deg)
  final double magX, magY, magZ, heading;
  // Fused AHRS Attitude (Degrees)
  final double roll, pitch;
  // Calibration & ZUPT Diagnostics
  final bool isStationary;
  final bool isCalibrating;
  final double calibrationProgress;
  final bool isMagCalibrated;
  final double variance;
  final DateTime timestamp;

  FullSensorTelemetry({
    required this.accX,
    required this.accY,
    required this.accZ,
    this.linAccX = 0.0,
    this.linAccY = 0.0,
    this.linAccZ = 0.0,
    required this.gyroX,
    required this.gyroY,
    required this.gyroZ,
    required this.magX,
    required this.magY,
    required this.magZ,
    required this.heading,
    this.roll = 0.0,
    this.pitch = 0.0,
    required this.isStationary,
    required this.isCalibrating,
    required this.calibrationProgress,
    required this.isMagCalibrated,
    required this.variance,
    required this.timestamp,
  });
}

class SensorOptimizationService {
  // EMA Filter coefficients & Physical Constants
  static const double _alphaAcc = 0.20;
  static const double _alphaGyro = 0.25;
  static const double _alphaMag = 0.15;
  static const double _complementaryGain = 0.96; // 96% Gyro + 4% Accel fusion
  static const double _standardGravity = 9.80665;

  // Filtered state variables
  double _filtAccX = 0.0, _filtAccY = 0.0, _filtAccZ = _standardGravity;
  double _filtGyroX = 0.0, _filtGyroY = 0.0, _filtGyroZ = 0.0;
  double _filtMagX = 0.0, _filtMagY = 0.0, _filtMagZ = 0.0;

  // Fused Attitude State (Radians)
  double _fusedRoll = 0.0;
  double _fusedPitch = 0.0;
  DateTime? _lastUpdate;

  // Dynamic Bias Offsets (In-Run Bias Stability Tracking)
  double _accBiasX = 0.0, _accBiasY = 0.0, _accBiasZ = 0.0;
  double _gyroBiasX = 0.0, _gyroBiasY = 0.0, _gyroBiasZ = 0.0;

  // 50-Sample Stationary Alignment State
  bool _isCalibrating = true;
  int _calSampleCount = 0;
  static const int _targetCalSamples = 50;
  double _sumAccX = 0.0, _sumAccY = 0.0, _sumAccZ = 0.0;
  double _sumGyroX = 0.0, _sumGyroY = 0.0, _sumGyroZ = 0.0;

  // Magnetometer Hard-Iron & Soft-Iron Ellipsoid Bounds
  double _magMinX = double.infinity, _magMaxX = double.negativeInfinity;
  double _magMinY = double.infinity, _magMaxY = double.negativeInfinity;
  double _magMinZ = double.infinity, _magMaxZ = double.negativeInfinity;

  // ZUPT Innovation Window
  final List<double> _magnitudeBuffer = [];
  static const int _windowSize = 15;
  static const double _stationaryThreshold = 0.012;

  final StreamController<FullSensorTelemetry> _controller =
      StreamController<FullSensorTelemetry>.broadcast();
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  SensorOptimizationService() {
    _initStreams();
  }

  Stream<FullSensorTelemetry> get telemetryStream => _controller.stream;

  void recalibrateAllSensors() {
    _isCalibrating = true;
    _calSampleCount = 0;
    _sumAccX = 0.0;
    _sumAccY = 0.0;
    _sumAccZ = 0.0;
    _sumGyroX = 0.0;
    _sumGyroY = 0.0;
    _sumGyroZ = 0.0;
    _fusedRoll = 0.0;
    _fusedPitch = 0.0;
    _magnitudeBuffer.clear();

    _magMinX = double.infinity;
    _magMaxX = double.negativeInfinity;
    _magMinY = double.infinity;
    _magMaxY = double.negativeInfinity;
    _magMinZ = double.infinity;
    _magMaxZ = double.negativeInfinity;
  }

  void _initStreams() {
    // 1. Gyroscope Stream
    _subscriptions.add(
      gyroscopeEventStream(samplingPeriod: SensorInterval.gameInterval).listen((event) {
        _filtGyroX = _alphaGyro * event.x + (1 - _alphaGyro) * _filtGyroX;
        _filtGyroY = _alphaGyro * event.y + (1 - _alphaGyro) * _filtGyroY;
        _filtGyroZ = _alphaGyro * event.z + (1 - _alphaGyro) * _filtGyroZ;
      }),
    );

    // 2. Magnetometer Stream
    _subscriptions.add(
      magnetometerEventStream(samplingPeriod: SensorInterval.gameInterval).listen((event) {
        _filtMagX = _alphaMag * event.x + (1 - _alphaMag) * _filtMagX;
        _filtMagY = _alphaMag * event.y + (1 - _alphaMag) * _filtMagY;
        _filtMagZ = _alphaMag * event.z + (1 - _alphaMag) * _filtMagZ;

        if (_filtMagX < _magMinX) _magMinX = _filtMagX;
        if (_filtMagX > _magMaxX) _magMaxX = _filtMagX;
        if (_filtMagY < _magMinY) _magMinY = _filtMagY;
        if (_filtMagY > _magMaxY) _magMaxY = _filtMagY;
        if (_filtMagZ < _magMinZ) _magMinZ = _filtMagZ;
        if (_filtMagZ > _magMaxZ) _magMaxZ = _filtMagZ;
      }),
    );

    // 3. Master Navigation Loop (Driven by Accelerometer Clock)
    _subscriptions.add(
      accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval).listen((event) {
        final now = DateTime.now();
        final double dt = _lastUpdate == null
            ? 0.02
            : (now.difference(_lastUpdate!).inMicroseconds / 1000000.0).clamp(0.001, 0.1);
        _lastUpdate = now;

        // Step A: Low-Pass EMA Filtering
        _filtAccX = _alphaAcc * event.x + (1 - _alphaAcc) * _filtAccX;
        _filtAccY = _alphaAcc * event.y + (1 - _alphaAcc) * _filtAccY;
        _filtAccZ = _alphaAcc * event.z + (1 - _alphaAcc) * _filtAccZ;

        // Step B: Multi-Sensor ZUPT Detector (Accel Variance + Gyro Energy)
        double mag = sqrt(
            _filtAccX * _filtAccX + _filtAccY * _filtAccY + _filtAccZ * _filtAccZ);
        if (_magnitudeBuffer.length >= _windowSize) {
          _magnitudeBuffer.removeAt(0);
        }
        _magnitudeBuffer.add(mag);

        double variance = 1.0;
        bool stationary = false;

        if (_magnitudeBuffer.length == _windowSize) {
          double mean = _magnitudeBuffer.reduce((a, b) => a + b) / _windowSize;
          variance = _magnitudeBuffer
                  .map((v) => (v - mean) * (v - mean))
                  .reduce((a, b) => a + b) /
              _windowSize;

          double unbiasedGx = _filtGyroX - _gyroBiasX;
          double unbiasedGy = _filtGyroY - _gyroBiasY;
          double unbiasedGz = _filtGyroZ - _gyroBiasZ;
          double gyroEnergy = sqrt(
              unbiasedGx * unbiasedGx + unbiasedGy * unbiasedGy + unbiasedGz * unbiasedGz);

          if (variance < _stationaryThreshold && gyroEnergy < 0.06) {
            stationary = true;
          }
        }

        // Step C: 50-Sample Coarse Alignment & Gyro Compassing
        if (_isCalibrating) {
          if (stationary || _magnitudeBuffer.length < _windowSize) {
            _sumAccX += _filtAccX;
            _sumAccY += _filtAccY;
            _sumAccZ += _filtAccZ;
            _sumGyroX += _filtGyroX;
            _sumGyroY += _filtGyroY;
            _sumGyroZ += _filtGyroZ;
            _calSampleCount++;

            if (_calSampleCount >= _targetCalSamples) {
              _accBiasX = _sumAccX / _targetCalSamples;
              _accBiasY = _sumAccY / _targetCalSamples;
              double avgZ = _sumAccZ / _targetCalSamples;
              double signZ = avgZ >= 0 ? 1.0 : -1.0;
              _accBiasZ = avgZ - (signZ * _standardGravity);

              _gyroBiasX = _sumGyroX / _targetCalSamples;
              _gyroBiasY = _sumGyroY / _targetCalSamples;
              _gyroBiasZ = _sumGyroZ / _targetCalSamples;

              _isCalibrating = false;
            }
          }
        }

        // Step D: In-Run Bias Stability & ZUPT Deadband Clamping
        double outAccX, outAccY, outAccZ;
        double outGyroX, outGyroY, outGyroZ;

        if (stationary && !_isCalibrating) {
          // Continuous Kalman-style bias tracking while stationary
          _accBiasX = 0.02 * _filtAccX + 0.98 * _accBiasX;
          _accBiasY = 0.02 * _filtAccY + 0.98 * _accBiasY;
          _gyroBiasX = 0.02 * _filtGyroX + 0.98 * _gyroBiasX;
          _gyroBiasY = 0.02 * _filtGyroY + 0.98 * _gyroBiasY;
          _gyroBiasZ = 0.02 * _filtGyroZ + 0.98 * _gyroBiasZ;

          outAccX = 0.0;
          outAccY = 0.0;
          outAccZ = _filtAccZ - _accBiasZ;

          outGyroX = 0.0;
          outGyroY = 0.0;
          outGyroZ = 0.0;
        } else {
          outAccX = _filtAccX - _accBiasX;
          outAccY = _filtAccY - _accBiasY;
          outAccZ = _filtAccZ - _accBiasZ;

          outGyroX = _filtGyroX - _gyroBiasX;
          outGyroY = _filtGyroY - _gyroBiasY;
          outGyroZ = _filtGyroZ - _gyroBiasZ;
        }

        // Step E: Complementary AHRS Attitude Filter (Roll & Pitch)
        double accelRoll = atan2(outAccY, outAccZ);
        double accelPitch = atan2(-outAccX, sqrt(outAccY * outAccY + outAccZ * outAccZ));

        if (stationary) {
          _fusedRoll = accelRoll;
          _fusedPitch = accelPitch;
        } else {
          _fusedRoll = _complementaryGain * (_fusedRoll + outGyroX * dt) +
              (1.0 - _complementaryGain) * accelRoll;
          _fusedPitch = _complementaryGain * (_fusedPitch + outGyroY * dt) +
              (1.0 - _complementaryGain) * accelPitch;
        }

        // Step F: Gravity Vector Projection & True Linear Acceleration
        double gravX = -_standardGravity * sin(_fusedPitch);
        double gravY = _standardGravity * sin(_fusedRoll) * cos(_fusedPitch);
        double gravZ = _standardGravity * cos(_fusedRoll) * cos(_fusedPitch);

        double linX = stationary ? 0.0 : (outAccX - gravX);
        double linY = stationary ? 0.0 : (outAccY - gravY);
        double linZ = stationary ? 0.0 : (outAccZ - gravZ);

        // Step G: Hard/Soft-Iron Ellipsoid Fitting & Tilt-Compensated Compass Heading
        double spanX = (_magMaxX.isFinite && _magMinX.isFinite) ? (_magMaxX - _magMinX) : 0.0;
        double spanY = (_magMaxY.isFinite && _magMinY.isFinite) ? (_magMaxY - _magMinY) : 0.0;
        double spanZ = (_magMaxZ.isFinite && _magMinZ.isFinite) ? (_magMaxZ - _magMinZ) : 0.0;

        bool magCalibrated = spanX > 15.0 && spanY > 15.0;
        double calMagX = _filtMagX;
        double calMagY = _filtMagY;
        double calMagZ = _filtMagZ;

        if (magCalibrated) {
          double offsetX = (_magMaxX + _magMinX) / 2.0;
          double offsetY = (_magMaxY + _magMinY) / 2.0;
          double offsetZ = (_magMaxZ + _magMinZ) / 2.0;

          double radX = spanX / 2.0;
          double radY = spanY / 2.0;
          double radZ = (spanZ > 5.0) ? (spanZ / 2.0) : ((radX + radY) / 2.0);
          double avgRad = (radX + radY + radZ) / 3.0;

          calMagX = (_filtMagX - offsetX) * (avgRad / radX);
          calMagY = (_filtMagY - offsetY) * (avgRad / radY);
          calMagZ = (_filtMagZ - offsetZ) * (avgRad / radZ);
        }

        // De-rotate magnetic vector into horizontal Earth frame using Roll & Pitch
        double cosRoll = cos(_fusedRoll);
        double sinRoll = sin(_fusedRoll);
        double cosPitch = cos(_fusedPitch);
        double sinPitch = sin(_fusedPitch);

        double magXh = calMagX * cosPitch +
            calMagY * sinRoll * sinPitch +
            calMagZ * cosRoll * sinPitch;
        double magYh = calMagY * cosRoll - calMagZ * sinRoll;

        double headingRad = atan2(-magYh, magXh);
        double headingDeg = (headingRad * 180.0 / pi + 360.0) % 360.0;

        double progress = (_calSampleCount / _targetCalSamples).clamp(0.0, 1.0);

        _controller.add(FullSensorTelemetry(
          accX: outAccX,
          accY: outAccY,
          accZ: outAccZ,
          linAccX: linX,
          linAccY: linY,
          linAccZ: linZ,
          gyroX: outGyroX,
          gyroY: outGyroY,
          gyroZ: outGyroZ,
          magX: calMagX,
          magY: calMagY,
          magZ: calMagZ,
          heading: headingDeg,
          roll: _fusedRoll * 180.0 / pi,
          pitch: _fusedPitch * 180.0 / pi,
          isStationary: stationary,
          isCalibrating: _isCalibrating,
          calibrationProgress: progress,
          isMagCalibrated: magCalibrated,
          variance: variance,
          timestamp: now,
        ));
      }),
    );
  }

  void dispose() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    _controller.close();
  }
}