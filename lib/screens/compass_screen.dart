import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/sensor_controller.dart';

class CompassScreen extends GetView<SensorController> {
  const CompassScreen({super.key});

  String getDirection(double heading) {
    if (heading >= 337.5 || heading < 22.5) {
      return 'N';
    } else if (heading < 67.5) {
      return 'NE';
    } else if (heading < 112.5) {
      return 'E';
    } else if (heading < 157.5) {
      return 'SE';
    } else if (heading < 202.5) {
      return 'S';
    } else if (heading < 247.5) {
      return 'SW';
    } else if (heading < 292.5) {
      return 'W';
    } else {
      return 'NW';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Compass',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Obx(() {
        final heading = controller.azimuth.value;
        final direction = getDirection(heading);

        return SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Heading
              Text(
                '${heading.toStringAsFixed(1)}°',
                style: const TextStyle(
                  fontSize: 46,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),

              const SizedBox(height: 4),

              // Direction
              Text(
                direction,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 25),

              // Compass
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 320,
                    height: 320,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer circle
                        Container(
                          width: 310,
                          height: 310,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 25,
                                spreadRadius: 2,
                                color: Colors.black.withOpacity(0.08),
                              ),
                            ],
                          ),
                        ),

                        // Compass rotating dial
                        Transform.rotate(
                          angle: -heading * math.pi / 180,
                          child: SizedBox(
                            width: 290,
                            height: 290,
                            child: CustomPaint(
                              painter: CompassPainter(),
                            ),
                          ),
                        ),

                        // Center indicator
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                          ),
                        ),

                        // Fixed top indicator
                        Positioned(
                          top: 3,
                          child: Column(
                            children: [
                              const Icon(
                                Icons.arrow_drop_up,
                                size: 38,
                              ),
                              Container(
                                width: 4,
                                height: 18,
                                decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(10),
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Info card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 18,
                      color: Colors.black.withOpacity(0.06),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
                  children: [
                    _InfoItem(
                      title: 'Heading',
                      value:
                      '${heading.toStringAsFixed(1)}°',
                    ),
                    Container(
                      width: 1,
                      height: 35,
                      color: Colors.grey.shade300,
                    ),
                    _InfoItem(
                      title: 'Direction',
                      value: direction,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        );
      }),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String title;
  final String value;

  const _InfoItem({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.grey.shade300;

    canvas.drawCircle(
      center,
      radius,
      paint,
    );

    // Tick marks
    for (int i = 0; i < 360; i += 10) {
      final angle = (i - 90) * math.pi / 180;

      final isMajor = i % 30 == 0;

      final outerRadius = radius - 5;
      final innerRadius =
      isMajor ? radius - 18 : radius - 12;

      final start = Offset(
        center.dx + innerRadius * math.cos(angle),
        center.dy + innerRadius * math.sin(angle),
      );

      final end = Offset(
        center.dx + outerRadius * math.cos(angle),
        center.dy + outerRadius * math.sin(angle),
      );

      final tickPaint = Paint()
        ..strokeWidth = isMajor ? 2.5 : 1.2
        ..color = isMajor
            ? Colors.black87
            : Colors.grey.shade400;

      canvas.drawLine(start, end, tickPaint);
    }

    // Cardinal directions
    const directions = {
      0: 'N',
      90: 'E',
      180: 'S',
      270: 'W',
    };

    for (final entry in directions.entries) {
      final angle =
          (entry.key - 90) * math.pi / 180;

      final textRadius = radius - 42;

      final position = Offset(
        center.dx + textRadius * math.cos(angle),
        center.dy + textRadius * math.sin(angle),
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: entry.value,
          style: TextStyle(
            fontSize: entry.value == 'N' ? 25 : 20,
            fontWeight: FontWeight.w800,
            color: entry.value == 'N'
                ? Colors.red
                : Colors.black87,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(
          position.dx - textPainter.width / 2,
          position.dy - textPainter.height / 2,
        ),
      );
    }

    // Degree numbers
    const degreeLabels = {
      45: '45',
      135: '135',
      225: '225',
      315: '315',
    };

    for (final entry in degreeLabels.entries) {
      final angle =
          (entry.key - 90) * math.pi / 180;

      final textRadius = radius - 65;

      final position = Offset(
        center.dx + textRadius * math.cos(angle),
        center.dy + textRadius * math.sin(angle),
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: entry.value,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(
          position.dx - textPainter.width / 2,
          position.dy - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}