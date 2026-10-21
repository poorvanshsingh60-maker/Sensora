import 'package:get/get.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../sensors/sensor_manager.dart';

class SensorController extends GetxController {
  final SensorManager sensorManager = SensorManager();

  // Accelerometer
  final accelerometerX = 0.0.obs;
  final accelerometerY = 0.0.obs;
  final accelerometerZ = 0.0.obs;

  // Gyroscope
  final gyroscopeX = 0.0.obs;
  final gyroscopeY = 0.0.obs;
  final gyroscopeZ = 0.0.obs;

  // Magnetometer
  final magnetometerX = 0.0.obs;
  final magnetometerY = 0.0.obs;
  final magnetometerZ = 0.0.obs;

  @override
  void onInit() {
    super.onInit();

    sensorManager.onAccelerometer = (event) {
      accelerometerX.value = event.x;
      accelerometerY.value = event.y;
      accelerometerZ.value = event.z;
    };

    sensorManager.onGyroscope = (event) {
      gyroscopeX.value = event.x;
      gyroscopeY.value = event.y;
      gyroscopeZ.value = event.z;
    };

    sensorManager.onMagnetometer = (event) {
      magnetometerX.value = event.x;
      magnetometerY.value = event.y;
      magnetometerZ.value = event.z;
    };

    sensorManager.startSensors();
  }

  @override
  void onClose() {
    sensorManager.stopSensors();
    super.onClose();
  }
}