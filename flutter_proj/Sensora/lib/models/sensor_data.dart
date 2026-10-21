import 'dart:math';

class SensorData {
  final double x;
  final double y;
  final double z;
  final DateTime timestamp;

  SensorData({
    required this.x,
    required this.y,
    required this.z,
    required this.timestamp,
  });

  double get magnitude {
    return sqrt(x * x + y * y + z * z);
  }
}