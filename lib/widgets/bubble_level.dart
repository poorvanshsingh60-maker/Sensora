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

    // Limit the angle so the bubble doesn't leave the level.
    final double x = tiltY.clamp(-45.0, 45.0);
    final double y = tiltX.clamp(-45.0, 45.0);

    // Maximum distance the bubble can travel from the center.
    const double maxOffset = 75;

    final double offsetX = (x / 45) * maxOffset;
    final double offsetY = (y / 45) * maxOffset;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer level
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
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

          // Center point
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
          ),

          // Bubble
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
                  size: 26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
