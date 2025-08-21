import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inventerization_4aas/constants/app_constants.dart';
import 'package:inventerization_4aas/models/api_response_model.dart';
import 'package:inventerization_4aas/models/transfer_model.dart';

class TransferRepository {
  Future<ApiResponse> createTransfer(Transfer transfer) async {
    try {
      // Проверка на валидность URL
      final url = Uri.tryParse('${AppConstants.baseAPIUrl}transfer/create.php');
      if (url == null) {
        return ApiResponse(success: false, message: 'Некорректный URL сервера');
      }

      // Заголовки запроса
      final headers = {'Content-Type': 'application/json'};

      print(transfer.name);

      // Тело запроса
      final body = json.encode(transfer.toJson());

      print(body);

      // Выполнение POST-запроса
      final response = await http.post(url, headers: headers, body: body);

      // Анализ HTTP-статуса
      if (response.statusCode != 200) {
        return ApiResponse(
          success: false,
          message: 'Ошибка HTTP: ${response.statusCode}',
        );
      }

      // Декодирование JSON
      late Map<String, dynamic> jsonMap;
      try {
        jsonMap = json.decode(response.body) as Map<String, dynamic>;
      } catch (e) {
        return ApiResponse(
          success: false,
          message: 'Не удалось декодировать JSON: $e',
        );
      }

      print('Ответ от сервера: $jsonMap');

      // Парсинг ответа в объект ApiResponse
      try {
        return ApiResponse.fromJson(jsonMap);
      } catch (e) {
        return ApiResponse(
          success: false,
          message: 'Ошибка парсинга ответа: $e',
        );
      }
    } catch (e, stackTrace) {
      // Ловим любые исключения и возвращаем их как часть ответа
      print('Произошла ошибка при создании перемещения: $e');
      print('Стек вызовов: $stackTrace');
      return ApiResponse(success: false, message: 'Внутренняя ошибка: $e');
    }
  }

  Future<ApiResponse> updateTransfer(Transfer transfer) async {
    final url = Uri.parse('${AppConstants.baseAPIUrl}transfer/update.php');

    final body = transfer
        .toJson(); // автоматически включает все поля, включая id

    print("[==+==] Че передаем в TransferUpdate");
    print(body);

    try {
      final response = await http.post(url, body: json.encode(body));
      final jsonMap = json.decode(response.body);
      return ApiResponse.fromJson(jsonMap);
    } catch (e) {
      return ApiResponse(success: false, message: 'Ошибка сети: $e');
    }
  }

  Future<ApiResponse> deleteTransfer(int id) async {
    final url = Uri.parse('${AppConstants.baseAPIUrl}transfer/delete.php');

    final body = {'id': id};

    try {
      final response = await http.post(url, body: json.encode(body));
      final jsonMap = json.decode(response.body);
      return ApiResponse.fromJson(jsonMap);
    } catch (e) {
      return ApiResponse(success: false, message: 'Ошибка сети: $e');
    }
  }

  Future<ApiResponse> loadTransfers(Map<String, dynamic> filters) async {
    final url = Uri.parse('${AppConstants.baseAPIUrl}transfer/load.php');

    try {
      print("[==+==] Грузим Transfers с фильтрами:");
      print(filters);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(filters),
      );

      if (response.statusCode != 200) {
        return ApiResponse(
          success: false,
          message: 'Ошибка HTTP: ${response.statusCode}',
        );
      }
      print(
        "[==+==] Получили результат: " + json.decode(response.body)['message'],
      );
      print(response.body);

      final jsonMap = json.decode(response.body);
      return ApiResponse.fromJson(jsonMap);
    } catch (e) {
      return ApiResponse(success: false, message: 'Ошибка сети: $e');
    }
  }

  Future<ApiResponse> getTransfersCountByMonthAndYear(
    int month,
    int year,
  ) async {
    final url = Uri.parse(
      '${AppConstants.baseAPIUrl}transfer/count_by_month_year.php',
    );

    final body = {'month': month, 'year': year};

    try {
      final response = await http.post(url, body: json.encode(body));
      final jsonMap = json.decode(response.body);
      return ApiResponse.fromJson(jsonMap);
    } catch (e) {
      return ApiResponse(success: false, message: 'Ошибка сети: $e');
    }
  }

  Future<ApiResponse> getLastTransferByInventoryItem(
    String inventoryItem,
  ) async {
    final url = Uri.tryParse(
      '${AppConstants.baseAPIUrl}transfer/get_last_transfer_for_object.php',
    );
    if (url == null) {
      return ApiResponse(success: false, message: 'Некорректный URL сервера');
    }

    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({'inventory_item': inventoryItem});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode != 200) {
        return ApiResponse(
          success: false,
          message: 'Ошибка HTTP: ${response.statusCode}',
        );
      }

      final jsonMap = json.decode(response.body);
      return ApiResponse.fromJson(jsonMap);
    } catch (e) {
      return ApiResponse(success: false, message: 'Ошибка сети: $e');
    }
  }
}
