class SensorRecordModel {
  final int? id;
  final int sessionId;
  final String sensorType; // accelerometer, gyroscope, magnetometer, orientation, light, proximity
  final DateTime timestamp;
  final int timeOffsetMs;
  final double x;
  final double y;
  final double z;
  final double magnitude;

  SensorRecordModel({
    this.id,
    required this.sessionId,
    required this.sensorType,
    required this.timestamp,
    required this.timeOffsetMs,
    required this.x,
    required this.y,
    required this.z,
    required this.magnitude,
  });

  /// For single-value sensors (e.g. ambient light in lux, proximity)
  double get value => x;
  double get lux => x;
  bool get isNear => x > 0.5;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'session_id': sessionId,
      'sensor_type': sensorType,
      'timestamp': timestamp.toIso8601String(),
      'time_offset_ms': timeOffsetMs,
      'x': x,
      'y': y,
      'z': z,
      'magnitude': magnitude,
    };
  }

  factory SensorRecordModel.fromMap(Map<String, dynamic> map) {
    return SensorRecordModel(
      id: map['id'] as int?,
      sessionId: map['session_id'] as int,
      sensorType: map['sensor_type'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      timeOffsetMs: (map['time_offset_ms'] as num).toInt(),
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
      z: (map['z'] as num).toDouble(),
      magnitude: (map['magnitude'] as num).toDouble(),
    );
  }
}
