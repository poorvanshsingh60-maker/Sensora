import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/sensor_controller.dart';
import '../widgets/sensor_graph.dart';

class SensorGraphsScreen extends StatelessWidget {
  SensorGraphsScreen({super.key});

  final SensorController controller =
  Get.find<SensorController>();

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
              'Sensors',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),

            SizedBox(height: 2),

            Text(
              'Live sensor telemetry',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),

        padding: const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          30,
        ),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),

            const SizedBox(height: 18),

            // ACCELEROMETER
            Obx(
                  () => SensorGraph(
                data: controller.accelerometerHistory
                    .toList(),
                title: 'Accelerometer',
              ),
            ),

            const SizedBox(height: 16),

            // GYROSCOPE
            Obx(
                  () => SensorGraph(
                data: controller.gyroscopeHistory
                    .toList(),
                title: 'Gyroscope',
              ),
            ),

            const SizedBox(height: 16),

            // MAGNETOMETER
            Obx(
                  () => SensorGraph(
                data: controller.magnetometerHistory
                    .toList(),
                title: 'Magnetometer',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: Colors.black.withValues(
            alpha: 0.05,
          ),
        ),

        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 4),
            color: Colors.black.withValues(
              alpha: 0.04,
            ),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,

            decoration: BoxDecoration(
              color: const Color(0xFFF0F2F7),
              borderRadius:
              BorderRadius.circular(14),
            ),

            child: const Icon(
              Icons.insights_rounded,
              size: 25,
            ),
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Graphs',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: 3),

                Text(
                  'Real-time readings from your sensors',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 5,
            ),

            decoration: BoxDecoration(
              color: const Color(0xFFEAF8F0),
              borderRadius:
              BorderRadius.circular(20),
            ),

            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  size: 7,
                  color: Color(0xFF35965D),
                ),

                SizedBox(width: 5),

                Text(
                  'LIVE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF35965D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}