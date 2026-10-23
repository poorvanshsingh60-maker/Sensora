import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sensora/controllers/sensor_controller.dart';
import 'package:sensora/main.dart';

void main() {
  testWidgets('Sensora app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AstrolabeApp());
    expect(find.text('SENSORA'), findsOneWidget);

    // Clean up controller timers to allow test runner to exit cleanly
    if (Get.isRegistered<SensorController>()) {
      Get.delete<SensorController>();
    }
  });
}
