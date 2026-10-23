import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/sensor_controller.dart';
import '../models/sensor_data.dart';
import '../widgets/bubble_level.dart';
import '../widgets/protractor.dart';

class SensorDashboard extends StatelessWidget {
  SensorDashboard({super.key});

  final SensorController controller =
  Get.put(SensorController());

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

      body: SafeArea(
        child: SingleChildScrollView(
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

            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // SECTION TITLE
  // ------------------------------------------------------------

  Widget _sectionTitle(
      String title,
      String subtitle,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
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
  // STATUS CARD
  // ------------------------------------------------------------

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),

        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF171923),
            Color(0xFF292C3A),
          ],
        ),

        boxShadow: [
          BoxShadow(
            blurRadius: 15,
            offset: const Offset(0, 6),
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
              color: Colors.white.withValues(
                alpha: 0.10,
              ),
            ),

            child: const Icon(
              Icons.sensors_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),

          const SizedBox(width: 15),

          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Sensors Active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Device telemetry is being monitored',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 10,
            height: 10,

            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF55D187),
            ),
          ),
        ],
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
          color: Colors.black.withValues(
            alpha: 0.05,
          ),
        ),

        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 4),
            color: Colors.black.withValues(
              alpha: 0.04,
            ),
          ),
        ],
      ),

      child: Obx(
            () {
          final data = sensor.value;

          return Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,

                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F2F7),
                      borderRadius:
                      BorderRadius.circular(11),
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
        crossAxisAlignment:
        CrossAxisAlignment.start,
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
          color: Colors.black.withValues(
            alpha: 0.05,
          ),
        ),

        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 4),
            color: Colors.black.withValues(
              alpha: 0.04,
            ),
          ),
        ],
      ),

      child: Obx(
            () => Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,

                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F2F7),
                    borderRadius:
                    BorderRadius.circular(11),
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
        crossAxisAlignment:
        CrossAxisAlignment.start,
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

  // ------------------------------------------------------------
  // BUBBLE LEVEL
  // ------------------------------------------------------------


  // ------------------------------------------------------------
  // INSTRUMENT VALUE
  // ------------------------------------------------------------

  Widget _instrumentValue(
      String label,
      double value,
      ) {
    return Column(
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
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}