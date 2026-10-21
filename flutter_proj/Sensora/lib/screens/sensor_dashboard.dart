import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/sensor_controller.dart';

class SensorDashboard extends StatelessWidget {
  SensorDashboard({super.key});

  final SensorController controller =
  Get.put(SensorController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Dashboard'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSensorCard(
              title: 'Accelerometer',
              x: controller.accelerometerX,
              y: controller.accelerometerY,
              z: controller.accelerometerZ,
            ),

            const SizedBox(height: 16),

            _buildSensorCard(
              title: 'Gyroscope',
              x: controller.gyroscopeX,
              y: controller.gyroscopeY,
              z: controller.gyroscopeZ,
            ),

            const SizedBox(height: 16),

            _buildSensorCard(
              title: 'Magnetometer',
              x: controller.magnetometerX,
              y: controller.magnetometerY,
              z: controller.magnetometerZ,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorCard({
    required String title,
    required RxDouble x,
    required RxDouble y,
    required RxDouble z,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Obx(
                  () => Column(
                children: [
                  _valueRow('X', x.value),
                  _valueRow('Y', y.value),
                  _valueRow('Z', z.value),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _valueRow(String axis, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            axis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value.toStringAsFixed(2),
          ),
        ],
      ),
    );
  }
}