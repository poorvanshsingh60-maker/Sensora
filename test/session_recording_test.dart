import 'package:flutter_test/flutter_test.dart';
import 'package:sensora/models/sensor_data.dart';
import 'package:sensora/models/sensor_record_model.dart';
import 'package:sensora/models/session_model.dart';
import 'package:sensora/sensors/sensor_processor.dart';
import 'package:sensora/controllers/sensor_controller.dart';

void main() {
  group('SessionModel Tests', () {
    test('SessionModel serialization and formatting with sensorTypes & samplingRate', () {
      final now = DateTime(2026, 10, 23, 12, 0, 0);
      final session = SessionModel(
        id: 1,
        title: 'Multi-Sensor Lab Run',
        startTime: now,
        endTime: now.add(const Duration(seconds: 75, milliseconds: 500)),
        durationMs: 75500,
        sampleCount: 1500,
        sensorTypes: 'Accelerometer, Gyroscope, Magnetometer, Orientation, Light, Proximity',
        samplingRate: 'Lab High-Speed (60 Hz)',
      );

      final map = session.toMap();
      expect(map['id'], 1);
      expect(map['title'], 'Multi-Sensor Lab Run');
      expect(map['duration_ms'], 75500);
      expect(map['sample_count'], 1500);
      expect(map['sensor_types'], 'Accelerometer, Gyroscope, Magnetometer, Orientation, Light, Proximity');
      expect(map['sampling_rate'], 'Lab High-Speed (60 Hz)');

      final restored = SessionModel.fromMap(map);
      expect(restored.id, session.id);
      expect(restored.title, session.title);
      expect(restored.durationMs, session.durationMs);
      expect(restored.sensorTypes, session.sensorTypes);
      expect(restored.samplingRate, 'Lab High-Speed (60 Hz)');
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

  group('Signal Processing & Rate Limiting Tests', () {
    test('LowPassFilter3D smooths jitter', () {
      final filter = LowPassFilter3D(alpha: 0.5);
      final raw1 = SensorData(x: 10, y: 10, z: 10, timestamp: DateTime.now());
      final filtered1 = filter.filter(raw1);
      expect(filtered1.x, 10.0);

      // Sudden spike of 20
      final raw2 = SensorData(x: 20, y: 10, z: 10, timestamp: DateTime.now());
      final filtered2 = filter.filter(raw2);
      // EMA: 0.5 * 20 + 0.5 * 10 = 15.0
      expect(filtered2.x, 15.0);
    });

    test('ScalarLowPassFilter smooths 1D signals', () {
      final filter = ScalarLowPassFilter(alpha: 0.2);
      filter.filter(100);
      final second = filter.filter(200);
      // EMA: 0.2 * 200 + 0.8 * 100 = 120.0
      expect(second, 120.0);
    });

    test('SensorRateLimiter enforces sampling frequency', () {
      final limiter = SensorRateLimiter();
      const intervalMs = 100; // 10 Hz

      // First sample at t = 0 ms -> allowed
      expect(limiter.shouldSample('accel', 0, intervalMs), isTrue);

      // Rapid event at t = 20 ms -> dropped
      expect(limiter.shouldSample('accel', 20, intervalMs), isFalse);

      // Rapid event at t = 80 ms -> dropped
      expect(limiter.shouldSample('accel', 80, intervalMs), isFalse);

      // Event at t = 105 ms -> allowed (>= 100ms)
      expect(limiter.shouldSample('accel', 105, intervalMs), isTrue);
    });
  });

  group('Safety Caps & Limits Tests', () {
    test('Safety threshold configuration values', () {
      expect(SensorController.maxRecordingDuration, const Duration(hours: 1));
      expect(SensorController.maxSampleLimit, 150000);
    });
  });
}
