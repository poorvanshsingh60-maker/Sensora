import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'screens/sensor_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SensoraApp());
}

class SensoraApp extends StatelessWidget {
  const SensoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sensora',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: SensorDashboard(),
    );
  }
}

typedef AstrolabeApp = SensoraApp;
