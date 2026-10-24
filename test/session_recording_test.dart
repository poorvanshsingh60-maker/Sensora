import 'package:flutter_test/flutter_test.dart';
import 'package:sensora/models/sensor_record_model.dart';
import 'package:sensora/models/session_model.dart';

void main() {
  group('SessionModel Tests', () {
    test('SessionModel serialization and formatting with sensorTypes', () {
      final now = DateTime(2026, 10, 23, 12, 0, 0);
      final session = SessionModel(
        id: 1,
        title: 'Multi-Sensor Lab Run',
        startTime: now,
        endTime: now.add(const Duration(seconds: 75, milliseconds: 500)),
        durationMs: 75500,
        sampleCount: 1500,
        sensorTypes: 'Accelerometer, Gyroscope, Magnetometer, Orientation, Light, Proximity',
      );

      final map = session.toMap();
      expect(map['id'], 1);
      expect(map['title'], 'Multi-Sensor Lab Run');
      expect(map['duration_ms'], 75500);
      expect(map['sample_count'], 1500);
      expect(map['sensor_types'], 'Accelerometer, Gyroscope, Magnetometer, Orientation, Light, Proximity');

      final restored = SessionModel.fromMap(map);
      expect(restored.id, session.id);
      expect(restored.title, session.title);
      expect(restored.durationMs, session.durationMs);
      expect(restored.sensorTypes, session.sensorTypes);
      expect(restored.sensorList.length, 6);
      expect(restored.sensorList.contains('Light'), isTrue);
      expect(restored.sensorList.contains('Proximity'), isTrue);
      expect(restored.formattedDuration, '01:15.5');
    });
  });

  group('SensorRecordModel Tests', () {
    test('SensorRecordModel serialization with 3-axis sensors', () {
      final now = DateTime.now();
      final record = SensorRecordModel(
        sessionId: 1,
        sensorType: 'accelerometer',
        timestamp: now,
        timeOffsetMs: 250,
        x: 0.12,
        y: 9.81,
        z: -0.05,
        magnitude: 9.811,
      );

      final map = record.toMap();
      expect(map['session_id'], 1);
      expect(map['sensor_type'], 'accelerometer');
      expect(map['time_offset_ms'], 250);
      expect(map['x'], 0.12);
      expect(map['y'], 9.81);
      expect(map['z'], -0.05);

      final restored = SensorRecordModel.fromMap(map);
      expect(restored.sessionId, 1);
      expect(restored.sensorType, 'accelerometer');
      expect(restored.timeOffsetMs, 250);
      expect(restored.x, 0.12);
      expect(restored.magnitude, 9.811);
    });

    test('SensorRecordModel serialization with scalar sensors (Light, Proximity)', () {
      final now = DateTime.now();
      final lightRecord = SensorRecordModel(
        sessionId: 1,
        sensorType: 'light',
        timestamp: now,
        timeOffsetMs: 100,
        x: 345.5,
        y: 0,
        z: 0,
        magnitude: 345.5,
      );

      expect(lightRecord.lux, 345.5);
      expect(lightRecord.value, 345.5);

      final proximityRecord = SensorRecordModel(
        sessionId: 1,
        sensorType: 'proximity',
        timestamp: now,
        timeOffsetMs: 150,
        x: 1.0,
        y: 0,
        z: 0,
        magnitude: 1.0,
      );

      expect(proximityRecord.isNear, isTrue);
    });
  });
}
