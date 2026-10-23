import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/sensor_controller.dart';
import '../widgets/sensor_card.dart';
import '../widgets/sensor_graph.dart';
import 'session_history_screen.dart';

class SensorDashboard extends StatelessWidget {
  SensorDashboard({super.key});

  final SensorController controller = Get.put(SensorController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SENSOR LABORATORY',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
        actions: [
          Obx(
            () => IconButton(
              icon: Badge(
                isLabelVisible: controller.sessions.isNotEmpty,
                label: Text('${controller.sessions.length}'),
                child: const Icon(Icons.folder_outlined),
              ),
              tooltip: 'Saved Sessions',
              onPressed: () {
                Get.to(() => const SessionHistoryScreen());
              },
            ),
          ),
        ],
      ),

      floatingActionButton: Obx(() {
        if (controller.isRecording.value) {
          return FloatingActionButton.extended(
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.stop_circle_rounded),
            label: const Text('Stop & Save'),
            onPressed: () => _handleStopRecording(context),
          );
        } else {
          return FloatingActionButton.extended(
            icon: const Icon(Icons.fiber_manual_record, color: Colors.redAccent),
            label: const Text('Record Session'),
            onPressed: () => _showStartRecordingDialog(context),
          );
        }
      }),

      body: Obx(
        () => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -----------------------------------------
              // RECORDING BANNER (ACTIVE OR IDLE)
              // -----------------------------------------
              if (controller.isRecording.value) ...[
                _buildActiveRecordingCard(context),
                const SizedBox(height: 16),
              ],

              // -----------------------------------------
              // HEADER
              // -----------------------------------------
              const Text(
                'Live Telemetry',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Real-time streaming from physical device sensors',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 20),

              // -----------------------------------------
              // ACCELEROMETER
              // -----------------------------------------
              SensorCard(
                title: 'Accelerometer',
                unit: 'm/s²',
                data: controller.accelerometer.value,
              ),

              const SizedBox(height: 12),

              SensorGraph(
                title: 'Accelerometer Graph',
                data: controller.accelerometerHistory,
              ),

              const SizedBox(height: 24),

              // -----------------------------------------
              // GYROSCOPE
              // -----------------------------------------
              SensorCard(
                title: 'Gyroscope',
                unit: 'rad/s',
                data: controller.gyroscope.value,
              ),

              const SizedBox(height: 12),

              SensorGraph(
                title: 'Gyroscope Graph',
                data: controller.gyroscopeHistory,
              ),

              const SizedBox(height: 24),

              // -----------------------------------------
              // MAGNETOMETER
              // -----------------------------------------
              SensorCard(
                title: 'Magnetometer',
                unit: 'µT',
                data: controller.magnetometer.value,
              ),

              const SizedBox(height: 12),

              SensorGraph(
                title: 'Magnetometer Graph',
                data: controller.magnetometerHistory,
              ),

              const SizedBox(height: 24),

              // -----------------------------------------
              // ORIENTATION
              // -----------------------------------------
              _buildOrientationCard(),

              const SizedBox(height: 80), // Padding for FloatingActionButton
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------------------------
  // ACTIVE RECORDING BANNER
  // -----------------------------------------

  Widget _buildActiveRecordingCard(BuildContext context) {
    final duration = controller.recordingDuration.value;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final tenths = ((duration.inMilliseconds.remainder(1000)) ~/ 100).toString();
    final timeStr = '$minutes:$seconds.$tenths';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade300, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'RECORDING IN PROGRESS',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                timeStr,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            controller.activeSessionTitle.value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${controller.recordingSampleCount.value} data points buffered to SQLite',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------
  // RECORDING DIALOGS & HANDLERS
  // -----------------------------------------

  void _showStartRecordingDialog(BuildContext context) {
    final defaultTitle = 'Session ${DateFormat('MMM dd HH:mm').format(DateTime.now())}';
    final textController = TextEditingController(text: defaultTitle);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Start Recording Session'),
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
              decoration: const InputDecoration(
                labelText: 'Session Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.bookmark_border_rounded),
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
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
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
        content: Text('Session saved ($sampleCount points). Tap History to view/export.'),
        action: SnackBarAction(
          label: 'View History',
          onPressed: () => Get.to(() => const SessionHistoryScreen()),
        ),
      ),
    );
  }

  // -----------------------------------------
  // ORIENTATION CARD
  // -----------------------------------------

  Widget _buildOrientationCard() {
    final double azimuthDegrees = controller.azimuth.value * 180 / pi;
    final double pitchDegrees = controller.pitch.value * 180 / pi;
    final double rollDegrees = controller.roll.value * 180 / pi;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Orientation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _orientationValue('Azimuth', azimuthDegrees, '°'),
            const SizedBox(height: 10),
            _orientationValue('Pitch', pitchDegrees, '°'),
            const SizedBox(height: 10),
            _orientationValue('Roll', rollDegrees, '°'),
          ],
        ),
      ),
    );
  }

  Widget _orientationValue(String name, double value, String unit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '${value.toStringAsFixed(1)} $unit',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
