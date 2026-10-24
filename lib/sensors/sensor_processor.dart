import '../models/sensor_data.dart';

/// Pre-configured recording sampling rates
enum SamplingRate {
  economy(
    hz: 10,
    label: 'Economy (10 Hz)',
    description: 'Long-duration environmental monitoring (battery friendly)',
  ),
  standard(
    hz: 25,
    label: 'Standard (25 Hz)',
    description: 'General movement & orientation tracking',
  ),
  highSpeed(
    hz: 60,
    label: 'Lab High-Speed (60 Hz)',
    description: 'High-velocity drop tests & vibration analysis',
  );

  final int hz;
  final String label;
  final String description;

  const SamplingRate({
    required this.hz,
    required this.label,
    required this.description,
  });

  /// Interval between samples in milliseconds
  int get intervalMs => (1000 / hz).round();
}

/// 3D Low-Pass Exponential Moving Average (EMA) filter for vector sensors
class LowPassFilter3D {
  double alpha;
  double? _x;
  double? _y;
  double? _z;

  LowPassFilter3D({this.alpha = 0.30}) : assert(alpha > 0.0 && alpha <= 1.0);

  /// Filters an incoming (x, y, z) vector using EMA:
  /// S_t = alpha * X_t + (1 - alpha) * S_{t-1}
  SensorData filter(SensorData raw) {
    if (_x == null || _y == null || _z == null) {
      _x = raw.x;
      _y = raw.y;
      _z = raw.z;
    } else {
      _x = alpha * raw.x + (1.0 - alpha) * _x!;
      _y = alpha * raw.y + (1.0 - alpha) * _y!;
      _z = alpha * raw.z + (1.0 - alpha) * _z!;
    }

    return SensorData(
      x: _x!,
      y: _y!,
      z: _z!,
      timestamp: raw.timestamp,
    );
  }

  /// Filters 3 arbitrary raw values
  ({double x, double y, double z}) filterValues(double x, double y, double z) {
    if (_x == null || _y == null || _z == null) {
      _x = x;
      _y = y;
      _z = z;
    } else {
      _x = alpha * x + (1.0 - alpha) * _x!;
      _y = alpha * y + (1.0 - alpha) * _y!;
      _z = alpha * z + (1.0 - alpha) * _z!;
    }
    return (x: _x!, y: _y!, z: _z!);
  }

  void reset() {
    _x = null;
    _y = null;
    _z = null;
  }
}

/// 1D Low-Pass EMA filter for scalar values (e.g. inclination, light, magnitude)
class ScalarLowPassFilter {
  double alpha;
  double? _val;

  ScalarLowPassFilter({this.alpha = 0.30}) : assert(alpha > 0.0 && alpha <= 1.0);

  double filter(double input) {
    if (_val == null) {
      _val = input;
    } else {
      _val = alpha * input + (1.0 - alpha) * _val!;
    }
    return _val!;
  }

  void reset() {
    _val = null;
  }
}

/// Rate-limiter ensuring samples are captured according to the chosen SamplingRate
class SensorRateLimiter {
  final Map<String, int> _lastSampleTimestamp = {};

  /// Checks if enough time has elapsed since the last recorded sample for this sensor type.
  bool shouldSample(String sensorType, int currentOffsetMs, int intervalMs) {
    final last = _lastSampleTimestamp[sensorType];
    if (last == null || (currentOffsetMs - last) >= intervalMs) {
      _lastSampleTimestamp[sensorType] = currentOffsetMs;
      return true;
    }
    return false;
  }

  void reset() {
    _lastSampleTimestamp.clear();
  }
}

/// Comprehensive signal processor uniting noise filtering and sampling downsampling
class SensorProcessor {
  final LowPassFilter3D accelerometerFilter;
  final LowPassFilter3D gyroscopeFilter;
  final LowPassFilter3D magnetometerFilter;
  final LowPassFilter3D orientationFilter;
  final ScalarLowPassFilter inclinationFilter;
  final SensorRateLimiter rateLimiter;

  bool enabled;

  SensorProcessor({
    double defaultAlpha = 0.35,
    this.enabled = true,
  })  : accelerometerFilter = LowPassFilter3D(alpha: defaultAlpha),
        gyroscopeFilter = LowPassFilter3D(alpha: defaultAlpha),
        magnetometerFilter = LowPassFilter3D(alpha: defaultAlpha),
        orientationFilter = LowPassFilter3D(alpha: defaultAlpha),
        inclinationFilter = ScalarLowPassFilter(alpha: defaultAlpha),
        rateLimiter = SensorRateLimiter();

  void setAlpha(double alpha) {
    final clamped = alpha.clamp(0.05, 1.0);
    accelerometerFilter.alpha = clamped;
    gyroscopeFilter.alpha = clamped;
    magnetometerFilter.alpha = clamped;
    orientationFilter.alpha = clamped;
    inclinationFilter.alpha = clamped;
  }

  SensorData processAccelerometer(SensorData raw) {
    return enabled ? accelerometerFilter.filter(raw) : raw;
  }

  SensorData processGyroscope(SensorData raw) {
    return enabled ? gyroscopeFilter.filter(raw) : raw;
  }

  SensorData processMagnetometer(SensorData raw) {
    return enabled ? magnetometerFilter.filter(raw) : raw;
  }

  ({double azimuth, double pitch, double roll}) processOrientation(
    double azimuth,
    double pitch,
    double roll,
  ) {
    if (!enabled) return (azimuth: azimuth, pitch: pitch, roll: roll);
    final filtered = orientationFilter.filterValues(azimuth, pitch, roll);
    return (azimuth: filtered.x, pitch: filtered.y, roll: filtered.z);
  }

  double processInclination(double angle) {
    return enabled ? inclinationFilter.filter(angle) : angle;
  }

  void reset() {
    accelerometerFilter.reset();
    gyroscopeFilter.reset();
    magnetometerFilter.reset();
    orientationFilter.reset();
    inclinationFilter.reset();
    rateLimiter.reset();
  }
}
