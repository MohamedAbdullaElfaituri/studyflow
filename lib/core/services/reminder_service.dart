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

  Future<void> requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _notifications
        .resolvePlatformSpecificImplementation<
            DarwinFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          'studyflow_general',
          'StudyFlow General',
          channelDescription: 'General reminders, exams, habits, and focus nudges',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );

  Future<void> showPreview({
    required int id,
    required String title,
    required String body,
  }) async {
    await _notifications.show(id, title, body, _details);
  }

  Future<void> showPomodoroComplete({
    required int id,
    required int minutes,
  }) async {
    await _notifications.show(
      id,
      'Focus session complete',
      '$minutes minute session saved to your timeline.',
      _details,
    );
  }

  Future<void> showHabitCelebration({
    required int id,
    required String title,
    required int streak,
  }) async {
    await _notifications.show(
      id,
      'Habit progress unlocked',
      '$title completed. Current streak: $streak.',
      _details,
    );
  }
}
