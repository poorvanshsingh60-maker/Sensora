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
      width: 320,
      height: 210,
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
      size.height - 25,
    );

    final radius = size.width * 0.42;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // --------------------------------------------------
    // PROTRACTOR ARC
    // --------------------------------------------------

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

    // --------------------------------------------------
    // BASE LINE
    // --------------------------------------------------

    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      paint,
    );

    // --------------------------------------------------
    // DEGREE MARKINGS
    // --------------------------------------------------

    for (int degree = 0; degree <= 180; degree += 10) {
      final radians = math.pi * degree / 180;

      final outerPoint = Offset(
        center.dx + radius * math.cos(radians),
        center.dy - radius * math.sin(radians),
      );

      final tickLength = degree % 30 == 0 ? 18.0 : 10.0;

      final innerRadius = radius - tickLength;

      final innerPoint = Offset(
        center.dx + innerRadius * math.cos(radians),
        center.dy - innerRadius * math.sin(radians),
      );

      canvas.drawLine(
        outerPoint,
        innerPoint,
        paint,
      );

      // Degree numbers
      if (degree % 30 == 0) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '$degree°',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();

        final textRadius = radius - 32;

        final textPosition = Offset(
          center.dx +
              textRadius * math.cos(radians) -
              textPainter.width / 2,
          center.dy -
              textRadius * math.sin(radians) -
              textPainter.height / 2,
        );

        textPainter.paint(
          canvas,
          textPosition,
        );
      }
    }

    // --------------------------------------------------
    // DEVICE ANGLE
    // --------------------------------------------------

    // Keep the displayed physical inclination
    // between -90° and +90°.
    final normalizedAngle = angle.clamp(-90.0, 90.0);

    final radians = math.pi * normalizedAngle / 180;

    final indicatorLength = radius - 25;

    final indicatorEnd = Offset(
      center.dx + indicatorLength * math.cos(radians),
      center.dy - indicatorLength * math.sin(radians),
    );

    // --------------------------------------------------
    // ANGLE INDICATOR
    // --------------------------------------------------

    final indicatorPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      center,
      indicatorEnd,
      indicatorPaint,
    );

    // --------------------------------------------------
    // CENTER POINT
    // --------------------------------------------------

    final centerPaint = Paint()
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      center,
      7,
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(
      covariant ProtractorPainter oldDelegate,
      ) {
    return oldDelegate.angle != angle;
  }
}