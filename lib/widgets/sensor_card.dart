import 'package:flutter/material.dart';

import '../models/sensor_data.dart';

class SensorCard extends StatelessWidget {
  final String title;
  final String unit;
  final SensorData data;

  const SensorCard({
    super.key,
    required this.title,
    required this.unit,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _axisValue('X', data.x, unit),
                _axisValue('Y', data.y, unit),
                _axisValue('Z', data.z, unit),
              ],
            ),

            const SizedBox(height: 16),

            const Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Magnitude',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${data.magnitude.toStringAsFixed(2)} $unit',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _axisValue(
      String axis,
      double value,
      String unit,
      ) {
    return Column(
      children: [
        Text(
          axis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          value.toStringAsFixed(2),
          style: const TextStyle(
            fontSize: 16,
          ),
        ),

        Text(
          unit,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}