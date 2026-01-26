import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inventerization_4aas/constants/app_constants.dart';
import 'package:inventerization_4aas/models/api_response_model.dart';

class CabinetRepository {
  Future<ApiResponse> loadCabinets() async {
    final url = Uri.parse('${AppConstants.baseAPIUrl}portalDB/get_cabinets.php');

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

      // print('Ответ от сервера: $jsonMap');

      try {
        return ApiResponse.fromJson(jsonMap);
      } catch (e) {
        return ApiResponse(
          success: false,
          message: 'Ошибка парсинга ответа: $e',
        );
      }
    } catch (e, stackTrace) {
      // print('Произошла ошибка при загрузке кабинетов: $e');
      // print('Стек вызовов: $stackTrace');
      return ApiResponse(success: false, message: 'Внутренняя ошибка: $e');
    }
  }
}