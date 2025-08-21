import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inventerization_4aas/constants/app_constants.dart';
import 'package:inventerization_4aas/models/api_response_model.dart';

class ProductRepository {
  /// Загружает список товаров с сервера
  Future<ApiResponse> loadProducts() async {
    final url = Uri.parse('${AppConstants.baseAPIUrl}rfidDB/get_products.php');

    try {
      final response = await http.get(url);

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

      print('Ответ от сервера: $jsonMap');

      try {
        return ApiResponse.fromJson(jsonMap);
      } catch (e) {
        return ApiResponse(
          success: false,
          message: 'Ошибка парсинга ответа: $e',
        );
      }
    } catch (e, stackTrace) {
      print('Произошла ошибка при загрузке товаров: $e');
      print('Стек вызовов: $stackTrace');
      return ApiResponse(success: false, message: 'Внутренняя ошибка: $e');
    }
  }
}