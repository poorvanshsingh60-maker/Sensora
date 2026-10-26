import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../sensors/sensor_processor.dart';
import '../database/database_helper.dart';
import '../models/sensor_data.dart';
import '../models/sensor_record_model.dart';
import '../models/session_model.dart';
import '../sensors/sensor_manager.dart';
import '../services/export_service.dart';
import '../services/notification_service.dart';

class SensorController extends GetxController {
  final SensorManager sensorManager = SensorManager();

  // --------------------------------------------------
  // ROTATION, ORIENTATION & TILT
  // --------------------------------------------------
  final RxBool isLowPassFilterEnabled = false.obs;

  final Rx<SamplingRate> selectedSamplingRate =
      SamplingRate.standard.obs;
  double _latestAzimuth = 0.0;
  double _latestPitch = 0.0;
  double _latestRoll = 0.0;
  double _latestProtractorAngle = 0.0;
  final RxInt shakeCount = 0.obs;
  final RxBool isShaking = false.obs;
  final RxDouble protractorAngle = 0.0.obs;
  final RxDouble tiltX = 0.0.obs;
  final RxDouble tiltY = 0.0.obs;
  final RxDouble azimuth = 0.0.obs;
  final RxDouble pitch = 0.0.obs;
  final RxDouble roll = 0.0.obs;
  final RxDouble light = 0.0.obs;
  final RxBool proximity = false.obs;

  final RxDouble bubbleX = 0.0.obs;
  final RxDouble bubbleY = 0.0.obs;

  // --------------------------------------------------
  // CURRENT SENSOR VALUES
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

  final RxList<SensorData> accelerometerHistory = <SensorData>[].obs;
  final RxList<SensorData> gyroscopeHistory = <SensorData>[].obs;
  final RxList<SensorData> magnetometerHistory = <SensorData>[].obs;

  static const int maxHistoryLength = 50;

  // --------------------------------------------------
  // LATEST RAW SAMPLES & UI THROTTLING
  // --------------------------------------------------

  SensorData? _latestAccelerometer;
  SensorData? _latestGyroscope;
  SensorData? _latestMagnetometer;
  Timer? _uiTimer;

  // UI updates every 200 ms = 5 FPS
  static const Duration uiUpdateInterval = Duration(milliseconds: 200);

  // --------------------------------------------------
  // SESSION RECORDING & SQLITE BUFFER
  // --------------------------------------------------

  // Safety limits: 1-Hour hard cap & 150,000 max sample ceiling
  static const Duration maxRecordingDuration = Duration(hours: 1);
  static const int maxSampleLimit = 100000;

  final RxBool isRecording = false.obs;
  final Rx<Duration> recordingDuration = Duration.zero.obs;
  final RxInt recordingSampleCount = 0.obs;
  final RxString activeSessionTitle = ''.obs;

  final RxList<SessionModel> sessions = <SessionModel>[].obs;
  final RxBool isLoadingSessions = false.obs;

  SessionModel? _activeSession;
  DateTime? _sessionStartTime;
  Timer? _recordingTimer;
  Timer? _bufferFlushTimer;
  final List<SensorRecordModel> _recordBuffer = [];
  final Set<String> _recordedSensorTypes = {};

  void _recordSample(SensorRecordModel record, String sensorType) {
    if (!isRecording.value || _activeSession?.id == null || _sessionStartTime == null) {
      return;
    }
    _recordBuffer.add(record);
    _recordedSensorTypes.add(sensorType);
    recordingSampleCount.value++;

    // 2. Max sample count safety cap
    if (recordingSampleCount.value >= maxSampleLimit) {
      stopRecording(autoStopReason: 'Max sample capacity (150,000) reached');
    }
  }

  // --------------------------------------------------
  // INITIALIZATION
  // --------------------------------------------------

  @override
  void onInit() {
    super.onInit();

    // 1. Orientation Listener
    sensorManager.onOrientation = (event) {
      _latestAzimuth = event.eulerAngles.azimuth;
      _latestPitch = event.eulerAngles.pitch;
      _latestRoll = event.eulerAngles.roll;

      pitch.value = _latestPitch * 180 / math.pi;
      roll.value = _latestRoll * 180 / math.pi;

      if (isRecording.value &&
          _activeSession?.id != null &&
          _sessionStartTime != null) {
        final now = DateTime.now();

        _recordSample(
          SensorRecordModel(
            sessionId: _activeSession!.id!,
            sensorType: 'orientation',
            timestamp: now,
            timeOffsetMs:
            now.difference(_sessionStartTime!).inMilliseconds,
            x: _latestAzimuth * 180 / math.pi,
            y: _latestPitch * 180 / math.pi,
            z: _latestRoll * 180 / math.pi,
            magnitude: 0,
          ),
          'Orientation',
        );
      }
    };

    //Compass Listener
    sensorManager.onCompass = (heading) {
      azimuth.value = heading;
    };
    // 2. Accelerometer Listener
    sensorManager.onAccelerometer = (event) {
      final now = DateTime.now();

      _latestAccelerometer = SensorData(
        x: event.x,
        y: event.y,
        z: event.z,
        timestamp: now,
      );

      // Calculate inclination from gravity (0° flat -> ~90° upright)
      final double inclination = math.atan2(
        math.sqrt(event.x * event.x + event.y * event.y),
        event.z.abs(),
      );
      _latestProtractorAngle = inclination * 180 / math.pi;

      if (isRecording.value && _activeSession?.id != null && _sessionStartTime != null) {
        _recordSample(
          SensorRecordModel(
            sessionId: _activeSession!.id!,
            sensorType: 'accelerometer',
            timestamp: now,
            timeOffsetMs: now.difference(_sessionStartTime!).inMilliseconds,
            x: event.x,
            y: event.y,
            z: event.z,
            magnitude: math.sqrt(
              event.x * event.x + event.y * event.y + event.z * event.z,
            ),
          ),
          'Accelerometer',
        );
      }
    };

    // 3. Gyroscope Listener
    sensorManager.onGyroscope = (event) {
      final now = DateTime.now();
      _latestGyroscope = SensorData(
        x: event.x,
        y: event.y,
        z: event.z,
        timestamp: now,
      );

      if (isRecording.value && _activeSession?.id != null && _sessionStartTime != null) {
        _recordSample(
          SensorRecordModel(
            sessionId: _activeSession!.id!,
            sensorType: 'gyroscope',
            timestamp: now,
            timeOffsetMs: now.difference(_sessionStartTime!).inMilliseconds,
            x: event.x,
            y: event.y,
            z: event.z,
            magnitude: math.sqrt(
              event.x * event.x + event.y * event.y + event.z * event.z,
            ),
          ),
          'Gyroscope',
        );
      }
    };

    // 4. Magnetometer Listener
    sensorManager.onMagnetometer = (event) {
      final now = DateTime.now();
      _latestMagnetometer = SensorData(
        x: event.x,
        y: event.y,
        z: event.z,
        timestamp: now,
      );
      if (isRecording.value && _activeSession?.id != null && _sessionStartTime != null) {
        _recordSample(
          SensorRecordModel(
            sessionId: _activeSession!.id!,
            sensorType: 'magnetometer',
            timestamp: now,
            timeOffsetMs: now.difference(_sessionStartTime!).inMilliseconds,
            x: event.x,
            y: event.y,
            z: event.z,
            magnitude: math.sqrt(
              event.x * event.x + event.y * event.y + event.z * event.z,
            ),
          ),
          'Magnetometer',
        );
      }
    };

    // Shake Listener
    sensorManager.onShake = () {
      shakeCount.value++;
      isShaking.value = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        isShaking.value = false;
      });
    };

    // 5. Light Sensor Listener
    sensorManager.onLight = (value) {
      light.value = value;

      if (isRecording.value && _activeSession?.id != null && _sessionStartTime != null) {
        final now = DateTime.now();
        _recordSample(
          SensorRecordModel(
            sessionId: _activeSession!.id!,
            sensorType: 'light',
            timestamp: now,
            timeOffsetMs: now.difference(_sessionStartTime!).inMilliseconds,
            x: value,
            y: 0,
            z: 0,
            magnitude: value,
          ),
          'Light',
        );
      }
    };

    // 6. Proximity Sensor Listener
    sensorManager.onProximity = (value) {
      proximity.value = value;

      if (isRecording.value && _activeSession?.id != null && _sessionStartTime != null) {
        final now = DateTime.now();
        _recordSample(
          SensorRecordModel(
            sessionId: _activeSession!.id!,
            sensorType: 'proximity',
            timestamp: now,
            timeOffsetMs: now.difference(_sessionStartTime!).inMilliseconds,
            x: value ? 1.0 : 0.0,
            y: 0,
            z: 0,
            magnitude: value ? 1.0 : 0.0,
          ),
          'Proximity',
        );
      }
    };

    // Start hardware sensors
    sensorManager.startSensors();

    // Start controlled UI timer
    _startUiTimer();

    // Initialize notification service for ongoing recording notifications
    NotificationService.instance.init(
      onStopRequested: () => stopRecording(),
    );

    // Initial load of past sessions from SQLite
    loadSessions();

    // 3. Auto-recover any orphaned sessions from previous unexpected shutdowns
    _recoverOrphanedSessions();
  }

  // --------------------------------------------------
  // UI TIMER & CALCULATIONS
  // --------------------------------------------------

  void _startUiTimer() {
    _uiTimer = Timer.periodic(
      uiUpdateInterval,
      (_) => _updateUI(),
    );
  }

  void _updateUI() {
    pitch.value = _latestPitch * 180 / math.pi;
    protractorAngle.value = _latestProtractorAngle;
    roll.value = _latestRoll * 180 / math.pi;

    if (_latestAccelerometer != null) {
      accelerometer.value = _latestAccelerometer!;

      accelerometerHistory.add(_latestAccelerometer!);

      if (accelerometerHistory.length > maxHistoryLength) {
        accelerometerHistory.removeAt(0);
      }

      final x = _latestAccelerometer!.x;
      final y = _latestAccelerometer!.y;
      final z = _latestAccelerometer!.z;

      tiltX.value = math.atan2(
        x,
        math.sqrt(y * y + z * z),
      ) *
          180 /
          math.pi;

      tiltY.value = math.atan2(
        y,
        math.sqrt(x * x + z * z),
      ) *
          180 /
          math.pi;
    }

    if (_latestGyroscope != null) {
      gyroscope.value = _latestGyroscope!;

      gyroscopeHistory.add(_latestGyroscope!);

      if (gyroscopeHistory.length > maxHistoryLength) {
        gyroscopeHistory.removeAt(0);
      }
    }

    if (_latestMagnetometer != null) {
      magnetometer.value = _latestMagnetometer!;

      magnetometerHistory.add(_latestMagnetometer!);

      if (magnetometerHistory.length > maxHistoryLength) {
        magnetometerHistory.removeAt(0);
      }
    }
  }

  // --------------------------------------------------
  // SESSION RECORDING CONTROLS
  // --------------------------------------------------
  void setFilterEnabled(bool enabled) {
    isLowPassFilterEnabled.value = enabled;
  }
  Future<void> startRecording(
      String title, {
        SamplingRate? rate,
      }) async {
    if (isRecording.value) return;

    final trimmedTitle = title.trim().isEmpty ? 'Session ${DateTime.now().toIso8601String()}' : title.trim();
    final now = DateTime.now();

    final session = SessionModel(
      title: trimmedTitle,
      startTime: now,
      sensorTypes: 'Accelerometer, Gyroscope, Magnetometer, Orientation, Light, Proximity',
    );

    final sessionId = await DatabaseHelper.instance.insertSession(session);
    _activeSession = session.copyWith(id: sessionId);
    _sessionStartTime = now;
    activeSessionTitle.value = trimmedTitle;

    recordingDuration.value = Duration.zero;
    recordingSampleCount.value = 0;
    _recordBuffer.clear();
    _recordedSensorTypes.clear();
    isRecording.value = true;

    // 4. Show initial persistent ongoing recording notification
    NotificationService.instance.showRecordingNotification(
      title: trimmedTitle,
      formattedDuration: '00:00.0',
      sampleCount: 0,
    );

    // Elapsed timer updates duration display and ongoing notification
    int tickCounter = 0;
    _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_sessionStartTime != null && isRecording.value) {
        final elapsed = DateTime.now().difference(_sessionStartTime!);
        recordingDuration.value = elapsed;

        // 1. Hard safety cap (1 hour)
        if (elapsed >= maxRecordingDuration) {
          stopRecording(autoStopReason: '1-hour safety cap reached');
          return;
        }

        // 4. Update ongoing notification every 1 second (10 ticks * 100ms)
        tickCounter++;
        if (tickCounter >= 10) {
          tickCounter = 0;
          NotificationService.instance.showRecordingNotification(
            title: activeSessionTitle.value,
            formattedDuration: _formatDuration(elapsed),
            sampleCount: recordingSampleCount.value,
          );
        }
      }
    });

    // High-performance batch buffer flush every 500ms
    _bufferFlushTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _flushBuffer();
    });
  }

  Future<void> stopRecording({String? autoStopReason}) async {
    if (!isRecording.value || _activeSession == null) return;

    isRecording.value = false;
    _recordingTimer?.cancel();
    _bufferFlushTimer?.cancel();

    // 4. Cancel persistent ongoing recording notification
    await NotificationService.instance.cancelRecordingNotification();

    // Flush any remaining records in memory to SQLite
    await _flushBuffer();

    final now = DateTime.now();
    final durationMs = _sessionStartTime != null ? now.difference(_sessionStartTime!).inMilliseconds : 0;
    final totalSamples = recordingSampleCount.value;

    final capturedTypes = _recordedSensorTypes.isNotEmpty
        ? _recordedSensorTypes.join(', ')
        : 'Accelerometer, Gyroscope, Magnetometer, Orientation';

    final finalizedSession = _activeSession!.copyWith(
      endTime: now,
      durationMs: durationMs,
      sampleCount: totalSamples,
      sensorTypes: capturedTypes,
    );

    await DatabaseHelper.instance.updateSession(finalizedSession);

    final sessionTitle = _activeSession!.title;
    _activeSession = null;
    _sessionStartTime = null;
    _recordedSensorTypes.clear();

    // Refresh history list
    await loadSessions();

    // If auto-stopped by safety caps (1h or sample limit), notify the user
    if (autoStopReason != null) {
      await NotificationService.instance.showAutoStopNotification(
        title: sessionTitle,
        reason: autoStopReason,
      );
      Get.snackbar(
        'Recording Auto-Stopped',
        '$sessionTitle was automatically saved: $autoStopReason.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      final hours = d.inHours.toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  Future<void> _recoverOrphanedSessions() async {
    try {
      final orphaned = await DatabaseHelper.instance.getOrphanedSessions();
      if (orphaned.isNotEmpty) {
        for (final session in orphaned) {
          await DatabaseHelper.instance.recoverOrphanedSession(session);
        }
        debugPrint('Sensora: Recovered ${orphaned.length} orphaned session(s).');
        await loadSessions();
        Get.snackbar(
          'Session Auto-Recovered',
          'Recovered ${orphaned.length} recording session(s) left open from a previous session.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      debugPrint('Error recovering orphaned sessions: $e');
    }
  }

  Future<void> _flushBuffer() async {
    if (_recordBuffer.isEmpty) return;

    final toInsert = List<SensorRecordModel>.from(_recordBuffer);
    _recordBuffer.clear();

    try {
      await DatabaseHelper.instance.insertBatchRecords(toInsert);
    } catch (e) {
      debugPrint('Failed to flush sensor records batch: $e');
    }
  }

  // --------------------------------------------------
  // SESSION HISTORY & EXPORT OPERATIONS
  // --------------------------------------------------

  Future<void> loadSessions() async {
    isLoadingSessions.value = true;
    try {
      final fetched = await DatabaseHelper.instance.getAllSessions();
      sessions.assignAll(fetched);
    } catch (e) {
      debugPrint('Failed to load sessions: $e');
    } finally {
      isLoadingSessions.value = false;
    }
  }

  Future<void> deleteSession(int id) async {
    await DatabaseHelper.instance.deleteSession(id);
    sessions.removeWhere((s) => s.id == id);
  }

  Future<ExportResult> exportCsv(SessionModel session) async {
    return await ExportService.instance.exportSessionToCsv(session);
  }

  Future<ExportResult> exportJson(SessionModel session) async {
    return await ExportService.instance.exportSessionToJson(session);
  }

  // --------------------------------------------------
  // CLEANUP
  // --------------------------------------------------

  @override
  void onClose() {
    _uiTimer?.cancel();
    _recordingTimer?.cancel();
    _bufferFlushTimer?.cancel();
    _flushBuffer();
    NotificationService.instance.cancelRecordingNotification();
    sensorManager.stopSensors();
    super.onClose();
  }
}
