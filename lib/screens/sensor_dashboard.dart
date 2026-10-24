import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/sensor_controller.dart';
import '../models/sensor_data.dart';

class SensorDashboard extends StatelessWidget {
  SensorDashboard({super.key});

  final SensorController controller = Get.put(SensorController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        elevation: 0,
        surfaceTintColor: Colors.transparent,

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SENSORA',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'Sensor Laboratory',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: Obx(() {
        if (controller.isRecording.value) {
          return FloatingActionButton.extended(
            backgroundColor: const Color(0xFFE53E3E),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.stop_circle_rounded),
            label: const Text('Stop & Save'),
            onPressed: () => _handleStopRecording(context),
          );
        } else {
          return FloatingActionButton.extended(
            backgroundColor: const Color(0xFF171923),
            foregroundColor: Colors.white,
            icon: const Icon(
              Icons.fiber_manual_record,
              color: Color(0xFFE53E3E),
              size: 18,
            ),
            label: const Text('Record Session'),
            onPressed: () => _showStartRecordingDialog(context),
          );
        }
      }),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            80, // Space for FloatingActionButton
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusCard(),

              const SizedBox(height: 24),

              _sectionTitle(
                'Live Telemetry',
                'Real-time sensor readings',
              ),

              const SizedBox(height: 14),

              _buildSensorCard(
                title: 'Accelerometer',
                icon: Icons.speed_rounded,
                sensor: controller.accelerometer,
                unit: 'm/s²',
              ),

              const SizedBox(height: 12),

              _buildSensorCard(
                title: 'Gyroscope',
                icon: Icons.rotate_right_rounded,
                sensor: controller.gyroscope,
                unit: 'rad/s',
              ),

              const SizedBox(height: 12),

              _buildSensorCard(
                title: 'Magnetometer',
                icon: Icons.explore_rounded,
                sensor: controller.magnetometer,
                unit: 'µT',
              ),

              const SizedBox(height: 12),

              _buildRotationCard(),

              const SizedBox(height: 28),
              Obx(
                    () => _buildValueCard(
                  icon: Icons.light_mode_rounded,
                  title: 'Ambient Light',
                  value: '${controller.light.value.toStringAsFixed(1)} lux',
                ),
              ),

              const SizedBox(height: 28),
              Obx(
                    () => _buildValueCard(
                  icon: Icons.sensors_rounded,
                  title: 'Proximity',
                  value: controller.proximity.value ? 'Near' : 'Far',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // SECTION TITLE
  // ------------------------------------------------------------
  Widget _buildValueCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.blue.withValues(alpha: 0.1),
              ),
              child: Icon(icon),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _sectionTitle(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // STATUS CARD (LIVE MONITORING / RECORDING STATE)
  // ------------------------------------------------------------

  Widget _buildStatusCard() {
    return Obx(() {
      final isRec = controller.isRecording.value;
      final duration = controller.recordingDuration.value;
      final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
      final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
      final tenths = ((duration.inMilliseconds.remainder(1000)) ~/ 100).toString();
      final timeStr = '$minutes:$seconds.$tenths';

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isRec
                ? [
                    const Color(0xFF381010),
                    const Color(0xFF1E1015),
                  ]
                : [
                    const Color(0xFF171923),
                    const Color(0xFF292C3A),
                  ],
          ),
          boxShadow: const [
            BoxShadow(
              blurRadius: 15,
              offset: Offset(0, 6),
              color: Colors.black12,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isRec
                    ? const Color(0xFFE53E3E).withValues(alpha: 0.20)
                    : Colors.white.withValues(alpha: 0.10),
              ),
              child: Icon(
                isRec ? Icons.fiber_smart_record_rounded : Icons.sensors_rounded,
                color: isRec ? const Color(0xFFFF6B6B) : Colors.white,
                size: 27,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRec ? 'Recording Session ($timeStr)' : 'Sensors Active',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isRec
                        ? '${controller.recordingSampleCount.value} data points buffered to SQLite'
                        : 'Device telemetry is being monitored',
                    style: TextStyle(
                      color: isRec ? Colors.white70 : Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isRec ? const Color(0xFFE53E3E) : const Color(0xFF55D187),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ------------------------------------------------------------
  // RECORDING DIALOGS & HANDLERS
  // ------------------------------------------------------------

  void _showStartRecordingDialog(BuildContext context) {
    final defaultTitle = 'Session ${DateFormat('MMM dd HH:mm').format(DateTime.now())}';
    final textController = TextEditingController(text: defaultTitle);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Start Recording Session',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Telemetry across all active sensors will be captured and persisted into local SQLite.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Session Title',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.bookmark_border_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.fiber_manual_record, color: Colors.white, size: 16),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.startRecording(textController.text);
            },
            label: const Text('Start'),
          ),
        ],
      ),
    );
  }

  void _handleStopRecording(BuildContext context) async {
    final sampleCount = controller.recordingSampleCount.value;
    await controller.stopRecording();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Session saved ($sampleCount data points). View under History tab.'),
      ),
    );
  }

  // ------------------------------------------------------------
  // SENSOR CARD
  // ------------------------------------------------------------

  Widget _buildSensorCard({
    required String title,
    required IconData icon,
    required Rx<SensorData> sensor,
    required String unit,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 4),
            color: Colors.black.withValues(alpha: 0.04),
          ),
        ],
      ),
      child: Obx(
        () {
          final data = sensor.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F2F7),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      icon,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.circle,
                    size: 8,
                    color: Color(0xFF55D187),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _axisValue('X', data.x),
                  _axisValue('Y', data.y),
                  _axisValue('Z', data.z),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // AXIS VALUE
  // ------------------------------------------------------------

  Widget _axisValue(
    String axis,
    double value,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            axis,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value.toStringAsFixed(2),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // ROTATION CARD
  // ------------------------------------------------------------

  Widget _buildRotationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 4),
            color: Colors.black.withValues(alpha: 0.04),
          ),
        ],
      ),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F2F7),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.navigation_rounded,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Rotation Sensor',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(
                  Icons.circle,
                  size: 8,
                  color: Color(0xFF55D187),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _angleValue(
                  'AZIMUTH',
                  controller.azimuth.value,
                ),
                _angleValue(
                  'PITCH',
                  controller.pitch.value,
                ),
                _angleValue(
                  'ROLL',
                  controller.roll.value,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // ANGLE VALUE
  // ------------------------------------------------------------

  Widget _angleValue(
    String label,
    double value,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${value.toStringAsFixed(1)}°',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
