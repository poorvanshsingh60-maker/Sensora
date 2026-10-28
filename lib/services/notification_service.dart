  import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const int recordingNotificationId = 888;
  static const int alertNotificationId = 889;

  static const String recordingChannelId = 'sensora_recording_channel';
  static const String recordingChannelName = 'Active Recording';
  static const String recordingChannelDesc =
      'Shows ongoing status while a sensor recording session is active';

  static const String alertChannelId = 'sensora_alerts_channel';
  static const String alertChannelName = 'Recording Alerts';
  static const String alertChannelDesc =
      'Alerts for recording auto-stop limits or completion';

  static const String actionStopRecording = 'action_stop_recording';

  VoidCallback? _onStopRequested;
  bool _isInitialized = false;

  Future<void> init({VoidCallback? onStopRequested}) async {
    _onStopRequested = onStopRequested;
    if (_isInitialized) return;

    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          if (response.actionId == actionStopRecording) {
            _onStopRequested?.call();
          }
        },
      );

      // Request permissions on Android 13+
      try {
        await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      } catch (e) {
        debugPrint('Notification permission request error: $e');
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('NotificationService init error (e.g. test environment): $e');
    }
  }

  /// Displays or updates the persistent ongoing notification during recording
  Future<void> showRecordingNotification({
    required String title,
    required String formattedDuration,
    required int sampleCount,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        recordingChannelId,
        recordingChannelName,
        channelDescription: recordingChannelDesc,
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        onlyAlertOnce: true,
        showWhen: true,
        actions: const <AndroidNotificationAction>[
          AndroidNotificationAction(
            actionStopRecording,
            'Stop Recording',
            showsUserInterface: true,
            cancelNotification: true,
          ),
        ],
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: false,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      await _notificationsPlugin.show(
        id: recordingNotificationId,
        title: 'Sensora Recording: $title',
        body: 'Duration: $formattedDuration | Samples: $sampleCount',
        notificationDetails: details,
      );
    } catch (e) {
      debugPrint('Failed to show recording notification: $e');
    }
  }

  /// Cancels the ongoing recording notification
  Future<void> cancelRecordingNotification() async {
    try {
      await _notificationsPlugin.cancel(id: recordingNotificationId);
    } catch (e) {
      debugPrint('Failed to cancel recording notification: $e');
    }
  }

  /// Shows an alert when recording is auto-stopped (1h limit, max sample count)
  Future<void> showAutoStopNotification({
    required String title,
    required String reason,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        alertChannelId,
        alertChannelName,
        channelDescription: alertChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        autoCancel: true,
        showWhen: true,
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      await _notificationsPlugin.show(
        id: alertNotificationId,
        title: 'Recording Auto-Stopped',
        body: '$title was automatically stopped: $reason.',
        notificationDetails: details,
      );
    } catch (e) {
      debugPrint('Failed to show auto stop notification: $e');
    }
  }
}
