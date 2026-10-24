import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/sensor_controller.dart';
import '../widgets/bubble_level.dart';
import '../widgets/protractor.dart';

class SensorToolsScreen extends StatelessWidget {
  SensorToolsScreen({super.key});

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
              'Instruments',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Orientation & measurement tools',
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
          children: [
            _buildBubbleLevelCard(),

            const SizedBox(height: 16),

            _buildProtractorCard(),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BUBBLE LEVEL
  // ------------------------------------------------------------

  Widget _buildBubbleLevelCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),

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

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _toolIcon(
                Icons.radio_button_checked_rounded,
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bubble Level',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    SizedBox(height: 2),

                    Text(
                      'Real-time device tilt',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              _liveIndicator(),
            ],
          ),

          const SizedBox(height: 24),

          // Actual live bubble level
          Center(
            child: Obx(
                  () => BubbleLevel(
                tiltX: controller.pitch.value,
                tiltY: controller.roll.value,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Live values
          Obx(
                () => Row(
              children: [
                Expanded(
                  child: _angleBox(
                    label: 'PITCH',
                    value: controller.pitch.value,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _angleBox(
                    label: 'ROLL',
                    value: controller.roll.value,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // PROTRACTOR
  // ------------------------------------------------------------

  Widget _buildProtractorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),

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

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _toolIcon(
                Icons.architecture_rounded,
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Protractor',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    SizedBox(height: 2),

                    Text(
                      'Measure device inclination',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              _liveIndicator(),
            ],
          ),

          const SizedBox(height: 24),

          // Actual live protractor
          Center(
            child: Obx(
                  () => Protractor(
                angle: controller.protractorAngle.value,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Current angle
          Obx(
                () => Center(
              child: Column(
                children: [
                  Text(
                    '${controller.protractorAngle.value.toStringAsFixed(1)}°',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 3),

                  const Text(
                    'Inclination',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SMALL UI COMPONENTS
  // ------------------------------------------------------------

  Widget _toolIcon(IconData icon) {
    return Container(
      width: 44,
      height: 44,

      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F7),
        borderRadius: BorderRadius.circular(13),
      ),

      child: Icon(
        icon,
        size: 23,
      ),
    );
  }

  Widget _liveIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFFEAF8F0),
        borderRadius: BorderRadius.circular(20),
      ),

      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 7,
            color: Color(0xFF55D187),
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
    );
  }

  Widget _angleBox({
    required String label,
    required double value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FB),
        borderRadius: BorderRadius.circular(15),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: Colors.grey,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            '${value.toStringAsFixed(1)}°',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}