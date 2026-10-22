import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/sensor_controller.dart';
import '../widgets/sensor_card.dart';
import '../widgets/sensor_graph.dart';

class SensorDashboard extends StatelessWidget {
  SensorDashboard({super.key});

  final SensorController controller =
  Get.put(SensorController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ASTROLABE'),
      ),

      body: Obx(
            () => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // -----------------------------------------
              // HEADER
              // -----------------------------------------

              const Text(
                'Sensor Dashboard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Live readings from your device sensors',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 24),

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

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------------------------
  // ORIENTATION CARD
  // -----------------------------------------

  Widget _buildOrientationCard() {
    final double azimuthDegrees =
        controller.azimuth.value * 180 / pi;

    final double pitchDegrees =
        controller.pitch.value * 180 / pi;

    final double rollDegrees =
        controller.roll.value * 180 / pi;

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

            _orientationValue(
              'Azimuth',
              azimuthDegrees,
              '°',
            ),

            const SizedBox(height: 10),

            _orientationValue(
              'Pitch',
              pitchDegrees,
              '°',
            ),

            const SizedBox(height: 10),

            _orientationValue(
              'Roll',
              rollDegrees,
              '°',
            ),
          ],
        ),
      ),
    );
  }

  Widget _orientationValue(
      String name,
      double value,
      String unit,
      ) {
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