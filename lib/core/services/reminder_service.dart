import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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

  Future<bool> areNotificationsAllowed() async {
    if (!isSupported) {
      return false;
    }

    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.areNotificationsEnabled() ?? false;
    }

    final ios = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return (await ios.checkPermissions())?.isEnabled ?? false;
    }

    final macos = _notifications.resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>();
    if (macos != null) {
      return (await macos.checkPermissions())?.isEnabled ?? false;
    }

    return true;
  }

  Future<bool> requestPermissions() async {
    if (!isSupported) {
      return false;
    }

    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? await areNotificationsAllowed();
    }

    final ios = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? await areNotificationsAllowed();
    }

    final macos = _notifications.resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>();
    if (macos != null) {
      final granted = await macos.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? await areNotificationsAllowed();
    }

    return true;
  }

  Future<void> cancelAll() async {
    if (!isSupported) {
      return;
    }

    await _notifications.cancelAll();
  }

  NotificationDetails _details({
    required String title,
    required String body,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'studyflow_instant',
        'StudyFlow',
        channelDescription: 'Fast StudyFlow reminders and progress updates',
        importance: Importance.max,
        priority: Priority.max,
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

    try {
      await _notifications.show(
        id,
        title,
        body,
        _details(title: title, body: body),
      );
    } on PlatformException {
      return;
    }
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
