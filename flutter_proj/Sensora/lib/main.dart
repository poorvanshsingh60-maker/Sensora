import 'package:flutter/material.dart';
import 'screens/sensor_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SensorDashboard(),
    ),
  );
}