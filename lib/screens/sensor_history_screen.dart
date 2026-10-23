import 'package:flutter/material.dart';

class SensorHistoryScreen extends StatelessWidget {
  const SensorHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        elevation: 0,
        surfaceTintColor: Colors.transparent,

        title: const Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              'History',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Sensor sessions & data',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),

      body: const Center(
        child: Text(
          'History coming next',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}