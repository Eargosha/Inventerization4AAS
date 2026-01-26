// cubit/notification_cubit.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventerization_4aas/models/notification_model.dart';
import 'package:inventerization_4aas/repositories/notification_repository.dart';
import 'package:inventerization_4aas/repositories/notification_service.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository repository;
  List<dynamic>? _userRoles;

  NotificationCubit({required this.repository}) : super(NotificationInitial());

  List<InvNotification> _notifications = [];

  void startPolling(List<dynamic> userRoles) {
    _userRoles = userRoles;
    // Проверяем каждые 60 секунд
    Future.delayed(Duration.zero, _fetchAndShowNew);
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _fetchAndShowNew();
    });
  }

  Timer? _pollingTimer;

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }

  Future<void> _fetchAndShowNew() async {
    final response = await repository.getNotifications();
    // print(
    //   "[==+==] Получили ответ от сервера: ${response.message} и это значит ${response.success}",
    // );
    // print("[==+==] Все уведоления: ${response.data}");
    if (response.success && response.data is List<InvNotification>) {
      final List<InvNotification> remote = response.data;
      // print("[==+==] Фильтруемся");
      // Фильтруем: только те, где есть моя роль
      final List<InvNotification> forMe = remote.where((n) {
        // print('[==+==] Уведомление для роли: ${n.destinationRoles}');
        // print('[==+==] Мои роли: ${_userRoles}');
        // Проверяем, есть ли хотя бы одна общая роль
        return n.destinationRoles
            .map((r) => r.toString())
            .any((role) => _userRoles!.contains(role));
      }).toList();
      // print("[==+==] Для меня уведомления: $forMe");

      // Находим новые
      final List<InvNotification> newOnes = forMe
          .where((n) => !_notifications.any((local) => (local.id == n.id)))
          .toList();

      // Добавляем в локальный список
      _notifications
        ..addAll(newOnes)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Показываем локальное уведомление для каждого нового
      for (final noti in newOnes) {
        if (!noti.isRead) {
          // print('[==+==] ПОКАЗЫВАЕМ УВЕДОМЛЕНИЕ: ${noti.title}');
          NotificationService().show(
            title: noti.title,
            body: noti.body,
            id: noti.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          );
        }
      }

      // print('[==+==] Перед Emit у нас получается такой список forMe:');
      // print(forMe);
      // print(
      //   '[==+==] Перед Emit у нас получается такой список локальных _notifications:',
      // );
      // print(_notifications);

      emit(NotificationUpdated(_notifications));
    }
  }

  void markAsRead(String id) {
    repository.markAsRead(id);
    _notifications = _notifications.map((n) {
      if (n.id == id) return n.copyWith(isRead: true);
      return n;
    }).toList();
    emit(NotificationUpdated(_notifications));
  }

  Future<void> sendNotification({
    required String title,
    required String body,
    required List<String> destinationRoles,
  }) async {
    final response = await repository.sendNotification(
      title: title,
      body: body,
      destinationRoles: destinationRoles,
    );

    if (response.success) {
      // Можно обновить список, если нужно
      await _fetchAndShowNew(); // перезагрузим, чтобы увидеть новое уведомление
    } else {
      // print('[==+==] Ошибка отправки уведомления: ${response.message}');
    }
  }

  List<InvNotification> get unread =>
      _notifications.where((n) => !n.isRead).toList();
  List<InvNotification> get all => _notifications;
}
