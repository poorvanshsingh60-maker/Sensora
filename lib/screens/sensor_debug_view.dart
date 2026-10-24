import 'package:flutter/material.dart';
import '../services/sensor_service.dart';
import '../database/app_database.dart';

class SensorDebugView extends StatefulWidget {
  const SensorDebugView({super.key});

  @override
  State<SensorDebugView> createState() => _SensorDebugViewState();
}

class _SensorDebugViewState extends State<SensorDebugView> {
  final SensorOptimizationService _sensorService = SensorOptimizationService();
  final AppDatabase _database = AppDatabase();

  FullSensorTelemetry? _telemetry;
  final List<SensorLogsTableCompanion> _batchQueue = [];
  int _totalLogged = 0;

  @override
  void initState() {
    super.initState();

    _sensorService.telemetryStream.listen((data) {
      if (mounted) {
        setState(() {
          _telemetry = data;
        });
      }

      if (!data.isCalibrating) {
        _batchQueue.add(SensorLogsTableCompanion.insert(
          accX: data.accX,
          accY: data.accY,
          accZ: data.accZ,
          gyroX: data.gyroX,
          gyroY: data.gyroY,
          gyroZ: data.gyroZ,
          magX: data.magX,
          magY: data.magY,
          magZ: data.magZ,
          heading: data.heading,
          isStationary: data.isStationary,
          timestamp: data.timestamp,
        ));

        if (_batchQueue.length >= 50) {
          final batchToInsert = List<SensorLogsTableCompanion>.from(_batchQueue);
          _batchQueue.clear();
          _database.batchInsertSensorLogs(batchToInsert);
          if (mounted) {
            setState(() {
              _totalLogged += batchToInsert.length;
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _sensorService.dispose();
    _database.close();
    super.dispose();
  }

  void _triggerRecalibration() {
    _sensorService.recalibrateAllSensors();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Recalibrating! Keep phone flat & still for Accel/Gyro, then wave in a Figure-8 for Magnetometer.',
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Widget _buildSensorCard(
    String title,
    IconData icon,
    Color accent,
    List<String> rows, {
    String? badgeText,
    Color? badgeColor,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(icon, color: accent),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (badgeColor ?? accent).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: badgeColor ?? accent),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: badgeColor ?? accent,
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(),
            ...rows.map((r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                  child: Text(
                    r,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 15),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = _telemetry;
    final isStationary = t?.isStationary ?? false;
    final isCalibrating = t?.isCalibrating ?? true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensora 9-DoF Calibration View'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Recalibrate All Sensors',
            onPressed: _triggerRecalibration,
          )
        ],
      ),
      body: t == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isCalibrating)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.2),
                        border: Border.all(color: Colors.blueAccent, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "CALIBRATING BASELINE OFFSETS...",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlueAccent,
                            ),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: t.calibrationProgress,
                            backgroundColor: Colors.white12,
                            color: Colors.lightBlueAccent,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Keep phone flat on desk (${(t.calibrationProgress * 100).toInt()}%)",
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isStationary
                            ? Colors.green.withOpacity(0.2)
                            : Colors.orange.withOpacity(0.2),
                        border: Border.all(
                          color: isStationary ? Colors.green : Colors.orange,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            isStationary
                                ? "ZUPT LOCKED (Stationary)"
                                : "ACTIVE MOTION DETECTED",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isStationary ? Colors.greenAccent : Colors.orangeAccent,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Roll: ${t.roll.toStringAsFixed(1)}° | Pitch: ${t.pitch.toStringAsFixed(1)}° | DB Rows: $_totalLogged",
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),

                  _buildSensorCard(
                    "Accelerometer & True Linear",
                    Icons.speed,
                    Colors.cyanAccent,
                    [
                      "Acc X : ${t.accX.toStringAsFixed(4)} m/s²",
                      "Acc Y : ${t.accY.toStringAsFixed(4)} m/s²",
                      "Acc Z : ${t.accZ.toStringAsFixed(4)} m/s²",
                      "Lin X : ${t.linAccX.toStringAsFixed(4)} m/s²",
                    ],
                    badgeText: isCalibrating ? "TARING" : "CALIBRATED",
                    badgeColor: isCalibrating ? Colors.amber : Colors.greenAccent,
                  ),

                  _buildSensorCard(
                    "Gyroscope (AHRS Fused)",
                    Icons.screen_rotation,
                    Colors.purpleAccent,
                    [
                      "Roll  (X): ${t.gyroX.toStringAsFixed(4)} rad/s",
                      "Pitch (Y): ${t.gyroY.toStringAsFixed(4)} rad/s",
                      "Yaw   (Z): ${t.gyroZ.toStringAsFixed(4)} rad/s",
                    ],
                    badgeText: isCalibrating ? "TARING" : "ZERO-LOCKED",
                    badgeColor: isCalibrating ? Colors.amber : Colors.greenAccent,
                  ),

                  _buildSensorCard(
                    "Magnetometer & Tilt Compass",
                    Icons.explore,
                    Colors.amberAccent,
                    [
                      "Mag X   : ${t.magX.toStringAsFixed(2)} µT",
                      "Mag Y   : ${t.magY.toStringAsFixed(2)} µT",
                      "Heading : ${t.heading.toStringAsFixed(1)}°",
                    ],
                    badgeText: t.isMagCalibrated ? "3D LOCKED" : "WAVE FIG-8",
                    badgeColor: t.isMagCalibrated ? Colors.greenAccent : Colors.orangeAccent,
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    onPressed: _triggerRecalibration,
                    icon: const Icon(Icons.tune),
                    label: const Text(
                      "RECALIBRATE ALL SENSORS",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}