// services/notification_service.dart

import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  late FlutterLocalNotificationsPlugin _notifications;

  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init() async {
    _notifications = FlutterLocalNotificationsPlugin();

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: DarwinInitializationSettings(),
      linux: LinuxInitializationSettings(defaultActionName: 'Open'),
      windows: WindowsInitializationSettings(
        appName: 'Inventarization4AAC',
        appUserModelId: 'com.example.inventerization_4aas',
        guid: '0c6a3e2f-47e2-478d-99d9-1b54bf4316ed',
      ),
    );

    await _notifications.initialize(initSettings);

    // Явно создаём канал (на Android)
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'notifications_channel',
        'Уведомления',
        description: 'Уведомления о задачах и событиях',
        importance: Importance.high,
      );
      await _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }
  }

  Future<void> show({
    required String title,
    required String body,
    String? id,
  }) async {
    try {
      // Генерируем уникальный ID если не предоставлен
      final notificationId =
          int.tryParse(
            id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          ) ??
          DateTime.now().millisecondsSinceEpoch.hashCode;

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'notifications_channel',
            'Уведомления',
            importance: Importance.high,
            priority: Priority.high,
          );

      const DarwinNotificationDetails darwinDetails =
          DarwinNotificationDetails();

      // Настройки для Windows. Показываются тут они только на Windows 10 последних обнволений и win 11
      const WindowsNotificationDetails windowsDetails =
          WindowsNotificationDetails();

      final NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
        linux: LinuxNotificationDetails(),
        windows: windowsDetails,
      );

      print('[NOTIFICATION] Попытка показать уведомление: $title');
      await _notifications.show(notificationId, title, body, details);
      print('[NOTIFICATION] Уведомление успешно показано');
    } catch (e) {
      print('[NOTIFICATION] Ошибка при показе уведомления: $e');
    }
  }
}
