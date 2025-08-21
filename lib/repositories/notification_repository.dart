// repositories/notification_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inventerization_4aas/constants/app_constants.dart';
import 'package:inventerization_4aas/models/api_response_model.dart';
import 'package:inventerization_4aas/models/notification_model.dart';

class NotificationRepository {
  Future<ApiResponse> getNotifications() async {
    final url = Uri.parse(
      '${AppConstants.baseAPIUrl}notification/get_notifications.php',
    );

    try {
      final response = await http.get(url);

      // Проверка HTTP-статуса
      if (response.statusCode != 200) {
        return ApiResponse(
          success: false,
          message: 'Ошибка HTTP: ${response.statusCode}',
        );
      }

      late Map<String, dynamic> jsonMap;
      try {
        jsonMap = json.decode(response.body) as Map<String, dynamic>;
      } catch (e) {
        return ApiResponse(
          success: false,
          message: 'Не удалось декодировать JSON: $e',
        );
      }

      print('Ответ от сервера (уведомления): $jsonMap');

      // Парсинг общего ответа через ApiResponse.fromJson
      final apiResponse = ApiResponse.fromJson(jsonMap);

      // Если успех — пытаемся извлечь и распарсить данные как уведомления
      if (apiResponse.success && apiResponse.data is List) {
        try {
          final List<InvNotification> notifications = (apiResponse.data as List)
              .map(
                (item) =>
                    InvNotification.fromJson(item as Map<String, dynamic>),
              )
              .toList();
          return ApiResponse(success: true, data: notifications);
        } catch (e) {
          return ApiResponse(
            success: false,
            message: 'Ошибка парсинга уведомлений: $e',
          );
        }
      }

      // Если данные не являются списком или ошибка
      return apiResponse;
    } catch (e, stackTrace) {
      print('Произошла ошибка при загрузке уведомлений: $e');
      print('Стек вызовов: $stackTrace');
      return ApiResponse(success: false, message: 'Внутренняя ошибка: $e');
    }
  }

  // Опционально: отметить как прочитанное
  Future<ApiResponse> markAsRead(String id) async {
    final url = Uri.parse(
      '${AppConstants.baseAPIUrl}notification/mark_as_read.php',
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': id}),
      );

      if (response.statusCode != 200) {
        return ApiResponse(
          success: false,
          message: 'Ошибка HTTP: ${response.statusCode}',
        );
      }

      late Map<String, dynamic> jsonMap;
      try {
        jsonMap = json.decode(response.body) as Map<String, dynamic>;
      } catch (e) {
        return ApiResponse(
          success: false,
          message: 'Не удалось декодировать JSON: $e',
        );
      }

      print('Ответ при отметке как прочитанное: $jsonMap');

      try {
        return ApiResponse.fromJson(jsonMap);
      } catch (e) {
        return ApiResponse(
          success: false,
          message: 'Ошибка парсинга ответа: $e',
        );
      }
    } catch (e, stackTrace) {
      print('Ошибка при отметке уведомления как прочитанного: $e');
      print('Стек вызовов: $stackTrace');
      return ApiResponse(success: false, message: 'Сетевая ошибка: $e');
    }
  }

  Future<ApiResponse> sendNotification({
    required String title,
    required String body,
    required List<String> destinationRoles,
  }) async {
    final url = Uri.parse(
      '${AppConstants.baseAPIUrl}notification/send_notification.php',
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'body': body,
          'destinationRoles': destinationRoles,
        }),
      );

      if (response.statusCode != 200) {
        return ApiResponse(
          success: false,
          message: 'Ошибка HTTP: ${response.statusCode}',
        );
      }

      late Map<String, dynamic> jsonMap;
      try {
        jsonMap = json.decode(response.body) as Map<String, dynamic>;
      } catch (e) {
        return ApiResponse(
          success: false,
          message: 'Не удалось декодировать JSON: $e',
        );
      }

      print('Ответ при отправке уведомления: $jsonMap');

      try {
        return ApiResponse.fromJson(jsonMap);
      } catch (e) {
        return ApiResponse(
          success: false,
          message: 'Ошибка парсинга ответа: $e',
        );
      }
    } catch (e, stackTrace) {
      print('Ошибка при отправке уведомления: $e');
      print('Стек вызовов: $stackTrace');
      return ApiResponse(success: false, message: 'Сетевая ошибка: $e');
    }
  }
}
