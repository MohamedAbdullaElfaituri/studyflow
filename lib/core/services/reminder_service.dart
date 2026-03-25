import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ReminderService {
  ReminderService(this._notifications);

  final FlutterLocalNotificationsPlugin _notifications;

  static Future<ReminderService> create() async {
    final notifications = FlutterLocalNotificationsPlugin();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await notifications.initialize(settings);
    return ReminderService(notifications);
  }

  Future<void> showPreview({
    required int id,
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'studyflow_general',
        'StudyFlow General',
        channelDescription: 'General reminders and focus nudges',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(id, title, body, details);
  }
}
