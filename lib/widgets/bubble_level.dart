import 'dart:math' as math;

import 'package:flutter/material.dart';

class BubbleLevel extends StatelessWidget {
  final double tiltX;
  final double tiltY;

  const BubbleLevel({
    super.key,
    required this.tiltX,
    required this.tiltY,
  });

  @override
  Widget build(BuildContext context) {
    const double size = 260;
    const double maxAngle = 45.0;
    const double maxOffset = 78.0;

    // Sensor values are in radians.
    final double pitchDegrees = tiltX ;
    final double rollDegrees = tiltY;

    // Limit movement so the bubble stays inside the level.
    final double pitch =
    pitchDegrees.clamp(-maxAngle, maxAngle).toDouble();

    final double roll =
    rollDegrees.clamp(-maxAngle, maxAngle).toDouble();

    // Roll controls horizontal movement.
    // Pitch controls vertical movement.
    final double offsetX = (roll / maxAngle) * maxOffset;
    final double offsetY = -(pitch / maxAngle) * maxOffset;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer circle
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF8F9FC),
              border: Border.all(
                width: 4,
              ),
            ),
          ),

          // Inner circle
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 2,
              ),
            ),
          ),

          // Horizontal guide
          const SizedBox(
            width: 180,
            height: 2,
          ),

          // Vertical guide
          const SizedBox(
            width: 2,
            height: 180,
          ),

          // Center target
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 2,
              ),
            ),
          ),

          // Moving bubble
          Transform.translate(
            offset: Offset(offsetX, offsetY),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 2,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.circle,
                  size: 25,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
