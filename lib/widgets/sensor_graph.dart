import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/sensor_data.dart';

class SensorGraph extends StatelessWidget {
  final List<SensorData> data;
  final String title;

  const   SensorGraph({
    super.key,
    required this.data,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 250,
        child: Center(
          child: Text('Waiting for sensor data...'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (data.length - 1).toDouble(),

                  gridData: const FlGridData(
                    show: true,
                  ),

                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                  ),

                  borderData: FlBorderData(
                    show: true,
                  ),

                  lineBarsData: [
                    _createLine(
                      data,
                          (sensor) => sensor.x,
                    ),
                    _createLine(
                      data,
                          (sensor) => sensor.y,
                    ),
                    _createLine(
                      data,
                          (sensor) => sensor.z,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Text('X'),
                Text('Y'),
                Text('Z'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  LineChartBarData _createLine(
      List<SensorData> data,
      double Function(SensorData) getValue,
      ) {
    return LineChartBarData(
      spots: List.generate(
        data.length,
            (index) {
          return FlSpot(
            index.toDouble(),
            getValue(data[index]),
          );
        },
      ),

      isCurved: true,

      dotData: const FlDotData(
        show: false,
      ),

      barWidth: 2,

      belowBarData: BarAreaData(
        show: false,
      ),
    );
  }
}