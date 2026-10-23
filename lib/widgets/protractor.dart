import 'dart:math' as math;

import 'package:flutter/material.dart';

class Protractor extends StatelessWidget {
  final double angle;

  const Protractor({
    super.key,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 180,
      child: CustomPaint(
        painter: ProtractorPainter(angle),
      ),
    );
  }
}

class ProtractorPainter extends CustomPainter {
  final double angle;

  ProtractorPainter(this.angle);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height - 20,
    );

    final radius = size.width * 0.42;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Main semicircle
    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: radius,
      ),
      math.pi,
      math.pi,
      false,
      paint,
    );

    // Base line
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      paint,
    );

    // Degree markings
    for (int degree = 0; degree <= 180; degree += 10) {
      final radians = math.pi * degree / 180;

      final outerPoint = Offset(
        center.dx + radius * math.cos(radians),
        center.dy - radius * math.sin(radians),
      );

      final innerRadius =
      degree % 30 == 0 ? radius - 18 : radius - 10;

      final innerPoint = Offset(
        center.dx + innerRadius * math.cos(radians),
        center.dy - innerRadius * math.sin(radians),
      );

      canvas.drawLine(
        outerPoint,
        innerPoint,
        paint,
      );
    }

    // Angle indicator
    final normalizedAngle = angle.clamp(-90.0, 90.0);

    final radians =
        math.pi * normalizedAngle / 180;

    final indicatorLength = radius - 25;

    final indicatorEnd = Offset(
      center.dx +
          indicatorLength * math.cos(radians),
      center.dy -
          indicatorLength * math.sin(radians),
    );

    final indicatorPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawLine(
      center,
      indicatorEnd,
      indicatorPaint,
    );

    // Center point
    final centerPaint = Paint()
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      center,
      6,
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ProtractorPainter oldDelegate) {
    return oldDelegate.angle != angle;
  }
}