import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../theme/app_colors.dart';

class ReminderService {
  ReminderService(
    this._notifications, {
    this.isSupported = true,
  });

  final FlutterLocalNotificationsPlugin _notifications;
  final bool isSupported;

  static Future<ReminderService> create() async {
    final notifications = FlutterLocalNotificationsPlugin();
    if (kIsWeb) {
      return ReminderService(notifications, isSupported: false);
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentBanner: true,
      defaultPresentList: true,
      defaultPresentSound: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);
    await notifications.initialize(settings);
    return ReminderService(notifications);
  }

  Future<void> requestPermissions() async {
    if (!isSupported) {
      return;
    }

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  NotificationDetails _details({
    required String title,
    required String body,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'studyflow_general',
        'StudyFlow',
        channelDescription: 'StudyFlow reminders and progress updates',
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
        color: AppColors.seed,
        colorized: true,
        enableLights: true,
        playSound: true,
        enableVibration: true,
        ticker: title,
        visibility: NotificationVisibility.public,
        subText: 'StudyFlow',
        styleInformation: BigTextStyleInformation(
          body,
          contentTitle: title,
          summaryText: 'StudyFlow',
        ),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentBanner: true,
        presentList: true,
        presentSound: true,
        subtitle: 'StudyFlow',
        threadIdentifier: 'studyflow_general',
        interruptionLevel: InterruptionLevel.active,
      ),
    );
  }

  Future<void> showMessage({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!isSupported) {
      return;
    }

    await _notifications.show(
        id, title, body, _details(title: title, body: body));
  }

  Future<void> showPreview({
    required int id,
    required String title,
    required String body,
  }) async {
    await showMessage(id: id, title: title, body: body);
  }

  Future<void> showPomodoroComplete({
    required int id,
    required String title,
    required String body,
  }) async {
    await showMessage(id: id, title: title, body: body);
  }

  Future<void> showHabitCelebration({
    required int id,
    required String title,
    required String body,
  }) async {
    await showMessage(id: id, title: title, body: body);
  }
}
