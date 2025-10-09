import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inventerization_4aas/constants/app_constants.dart';
import 'package:inventerization_4aas/models/api_response_model.dart';

class PrinterStatusRepository {
  Future<ApiResponse> printLabel({
    required String name,
    required String productId,
    required String barcode,
    required String rfid,
    required int labelType,
  }) async {
    // Пример Http запроса для печати:
    // http://10.104.224.75/flutter_api/printer/print_label.php?invNom=INV001&rfid=RFID123&nameTovar=StollMetal&barcode=123456789012&typeOfSticker=1
    final url = Uri.parse(
      '${AppConstants.baseAPIUrl}printer/print_label.php?invNom=$productId&rfid=$rfid&nameTovar=$name&barcode=$barcode&typeOfSticker=$labelType',
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        return ApiResponse(
          success: false,
          message: 'Ошибка HTTP: ${response.statusCode}',
        );
      }

      late Map<String, dynamic> jsonMap;
      try {
        final String rawBody = response.body.trim();

        // 🔍 Проверка: действительно ли это JSON?
        if (rawBody.isEmpty) {
          return ApiResponse(
            success: false,
            message: 'Сервер вернул пустой ответ',
          );
        }

        if (!rawBody.startsWith('{') && !rawBody.startsWith('[')) {
          // Это точно не JSON — возможно, ошибка сервера, HTML, текст и т.д.
          // Ограничиваем длину, чтобы не засорять логи
          final snippet = rawBody.length > 200
              ? '${rawBody.substring(0, 200)}...'
              : rawBody;
          return ApiResponse(
            success: false,
            message:
                'Сервер вернул недопустимый формат (ожидался JSON). Ответ: "$snippet"',
          );
        }

        // Только теперь пытаемся распарсить
        final jsonMap = json.decode(rawBody) as Map<String, dynamic>;
        return ApiResponse.fromJson(jsonMap);
      } catch (e) {
        return ApiResponse(
          success: false,
          message: 'Ошибка при обработке ответа сервера: $e',
        );
      }

      // print('Ответ при отправке печати: $jsonMap');

      // try {
      //   return ApiResponse.fromJson(jsonMap);
      // } catch (e) {
      //   return ApiResponse(
      //     success: false,
      //     message: 'Ошибка парсинга ответа: $e',
      //   );
      // }
    } catch (e, stackTrace) {
      print('Ошибка при отправке печати: $e');
      print('Стек вызовов: $stackTrace');
      return ApiResponse(success: false, message: 'Сетевая ошибка: $e');
    }
  }

  Future<ApiResponse> configurePrinter({
    required double labelLength,
    required double labelWidth,
    required bool isFrontAntenna,
    required double antennaX,
    required double antennaY,
    required double powerWrite,
    required double powerRead,
    required double pitchSize,
  }) async {
    final uri1 = Uri.parse(
      '${AppConstants.baseAPIUrl}printer/configure_sato.php?'
      'length=${labelLength}&width=${labelWidth}&antenna-pos=${!isFrontAntenna ? 'NORMAL' : 'FRONT'}',
    );

    final uri2 = Uri.parse(
      '${AppConstants.baseAPIUrl}printer/configure_sato.php?'
      'antenna-x=${antennaX}&antenna-y=${antennaY}&power-write=${powerWrite}&power-read=${powerRead}&pitch-size=${pitchSize}',
    );

    print('URL 1: $uri1');
    print('URL 2: $uri2');

    try {
      final response1 = await http.post(
        uri1,
        headers: {'Content-Type': 'application/json'},
      );
      final response2 = await http.post(
        uri2,
        headers: {'Content-Type': 'application/json'},
      );

      // Проверяем HTTP-статусы
      if (response1.statusCode != 200) {
        return ApiResponse(
          success: false,
          message: 'Ошибка HTTP (запрос 1): ${response1.statusCode}',
        );
      }
      if (response2.statusCode != 200) {
        return ApiResponse(
          success: false,
          message: 'Ошибка HTTP (запрос 2): ${response2.statusCode}',
        );
      }

      // Пытаемся распарсить JSON, но если не получается — НЕ СЧИТАЕМ ЭТО ОШИБКОЙ
      Map<String, dynamic>? jsonMap1;
      try {
        if (response1.body.trim().isNotEmpty) {
          jsonMap1 = json.decode(response1.body) as Map<String, dynamic>;
        }
      } catch (e) {
        // Игнорируем ошибку парсинга — возможно, сервер вернул не JSON
        print(
          '⚠️ Не удалось распарсить ответ 1 как JSON: $e. Тело: "${response1.body}"',
        );
      }

      Map<String, dynamic>? jsonMap2;
      try {
        if (response2.body.trim().isNotEmpty) {
          jsonMap2 = json.decode(response2.body) as Map<String, dynamic>;
        }
      } catch (e) {
        print(
          '⚠️ Не удалось распарсить ответ 2 как JSON: $e. Тело: "${response2.body}"',
        );
      }

      // Если хотя бы один ответ содержит success=true — считаем успехом
      bool hasSuccess = false;
      String? message;

      if (jsonMap1 != null) {
        hasSuccess = jsonMap1['success'] == true;
        message = jsonMap1['message'] as String?;
      }
      if (jsonMap2 != null && !hasSuccess) {
        hasSuccess = jsonMap2['success'] == true;
        message ??= jsonMap2['message'] as String?;
      }

      // 🔑 Главное: если статус 200 — считаем, что всё ОК, даже без JSON
      return ApiResponse(
        success: true,
        message:
            message ??
            'Конфигурация применена успешно (сервер не вернул структурированный ответ)',
      );
    } catch (e, stackTrace) {
      print('Сетевая ошибка при конфигурации принтера: $e');
      print('Стек: $stackTrace');
      return ApiResponse(success: false, message: 'Сетевая ошибка: $e');
    }
  }

  // Future<ApiResponse> configurePrinter({
  //   required double labelLength, // Длина этикетки в мм
  //   required double labelWidth, // Ширина этикетки в мм
  //   required bool
  //   isFrontAntenna, // Переднее положение антенны? (true = FRONT, false = NORMAL)
  //   required double antennaX, // Положение антенны по X в мм
  //   required double antennaY, // Положение антенны по Y в мм
  //   required double powerWrite, // Питание при записи в dBm
  //   required double powerRead, // Питание при чтении в dBm
  //   required double pitchSize, // Размер шага в мм
  // }) async {
  //   // Формируем URL с параметрами конфигурации
  //   final uri = Uri.parse(
  //     '${AppConstants.baseAPIUrl}printer/configure_sato.php?length=${labelLength.toString()}&width=${labelWidth.toString()}&antenna-pos=${!isFrontAntenna ? 'NORMAL' : 'FRONT'}',
  //   );

  //   // Формируем URL с параметрами конфигурации
  //   final uri2 = Uri.parse(
  //     '${AppConstants.baseAPIUrl}printer/configure_sato.php?antenna-x=${antennaX.toString()}&antenna-y=${antennaY.toString()}&power-write=${powerWrite.toString()}&power-read=${powerRead.toString()}&pitch-size=${pitchSize.toString()}',
  //   );

  //   // 👇 Добавьте эту строку для проверки
  //   print('Полный URL запроса 1 часть: ${uri.toString()}');
  //   print('Полный URL запроса 2 часть: ${uri.toString()}');

  //   try {
  //     final response = await http.post(
  //       uri,
  //       headers: {'Content-Type': 'application/json'},
  //     );

  //     final response2 = await http.post(
  //       uri2,
  //       headers: {'Content-Type': 'application/json'},
  //     );

  //     if (response.statusCode != 200) {
  //       return ApiResponse(
  //         success: false,
  //         message: 'Ошибка HTTP: ${response.statusCode}',
  //       );
  //     }

  //     if (response2.statusCode != 200) {
  //       return ApiResponse(
  //         success: false,
  //         message: 'Ошибка HTTP: ${response.statusCode}',
  //       );
  //     }

  //     late Map<String, dynamic> jsonMap;
  //     try {
  //       jsonMap = json.decode(response.body) as Map<String, dynamic>;
  //     } catch (e) {
  //       return ApiResponse(
  //         success: false,
  //         message: 'Не удалось декодировать JSON: $e',
  //       );
  //     }

  //     late Map<String, dynamic> jsonMap2;
  //     try {
  //       jsonMap2 = json.decode(response2.body) as Map<String, dynamic>;
  //     } catch (e) {
  //       return ApiResponse(
  //         success: false,
  //         message: 'Не удалось декодировать JSON: $e',
  //       );
  //     }

  //     print('Ответ при конфигурации принтера: $jsonMap');
  //     print('Ответ при конфигурации принтера 2: $jsonMap2');

  //     try {
  //       return ApiResponse.fromJson(jsonMap);
  //     } catch (e) {
  //       return ApiResponse(
  //         success: false,
  //         message: 'Ошибка парсинга ответа: $e',
  //       );
  //     }

  //   } catch (e, stackTrace) {
  //     print('Ошибка при конфигурации принтера: $e');
  //     print('Стек вызовов: $stackTrace');
  //     return ApiResponse(success: false, message: 'Сетевая ошибка: $e');
  //   }
  // }

  // Получение статуса принетера, готов он принимать команды или нет
  Future<ApiResponse> getPrinterStatus() async {
    final url = Uri.parse(
      '${AppConstants.baseAPIUrl}printer/get_sato_net_status.php',
    );

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
