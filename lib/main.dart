import 'package:flutter/material.dart';
import 'package:sensora/screens/main_navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const AstrolabeApp());
}

class AstrolabeApp extends StatelessWidget {
  const AstrolabeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Astrolabe',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
} 