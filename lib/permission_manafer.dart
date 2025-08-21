// services/permission_manager.dart

import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  /// Запрашивает все необходимые разрешения
  Future<bool> requestAppPermissions() async {
    // 1. Запрос на камеру
    final cameraStatus = await _requestCameraPermission();
    if (!cameraStatus) return false;

    // 2. Запрос на уведомления
    final notificationStatus = await _requestNotificationPermission();
    if (!notificationStatus) return false;

    return true;
  }

  /// Запрос доступа к камере
  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      print('✅ Разрешение на камеру получено');
      return true;
    } else if (status.isPermanentlyDenied) {
      print('❌ Доступ к камере запрещён навсегда. Перейдите в настройки.');
      openAppSettings(); // Открывает настройки приложения
      return false;
    } else {
      print('❌ Доступ к камере отклонён');
      return false;
    }
  }

  /// Запрос на уведомления (Android + iOS)
  Future<bool> _requestNotificationPermission() async {
    // На Android 13+ нужно запрашивать POST_NOTIFICATIONS
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      if (status.isGranted) {
        print('✅ Разрешение на уведомления получено');
        return true;
      } else if (status.isPermanentlyDenied) {
        print('❌ Уведомления отключены навсегда');
        openAppSettings();
        return false;
      } else {
        print('❌ Разрешение на уведомления отклонено');
        return false;
      }
    }

    return true; // Для других платформ
  }
}