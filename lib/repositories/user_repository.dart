import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inventerization_4aas/constants/app_constants.dart';
import 'package:inventerization_4aas/models/api_response_model.dart';
import 'package:inventerization_4aas/models/user_model.dart'; // Убедитесь, что путь верный

class UserRepository {
  // Метод для получения списка пользователей
  Future<List<User>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseAPIUrl}users/get_users.php'),
      );

      if (response.statusCode == 200) {
        // Преобразуем JSON-ответ в список объектов UserModel
        List<dynamic> usersJson = json.decode(response.body);
        print(usersJson);
        return usersJson.map((user) => User.fromJson(user)).toList();
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<ApiResponse> deleteUser(String id) async {
    final url = Uri.parse('${AppConstants.baseAPIUrl}users/delete.php');

    final body = {
      'id': id,
    };

    try {
      final response = await http.post(url, body: json.encode(body));
      final jsonMap = json.decode(response.body);
      return ApiResponse.fromJson(jsonMap);
    } catch (e) {
      return ApiResponse(success: false, message: 'Ошибка сети: $e');
    }
  }

  Future<ApiResponse> createUser(
    String login,
    String password,
    String firstName,
    String lastName,
    String patronymic,
    String roles,
  ) async {
    try {
      // Проверка на валидность URL
      final url = Uri.tryParse(
        '${AppConstants.baseAPIUrl}users/create_user.php',
      );
      if (url == null) {
        return ApiResponse(success: false, message: 'Некорректный URL сервера');
      }

      // Заголовки запроса
      final headers = {'Content-Type': 'application/json'};

      // Тело запроса
      final body = json.encode({
        'login': login,
        'firstName': firstName,
        'lastName': lastName,
        'patronymic': patronymic,
        'password': password,
        'roles': roles,
      });

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

      // print('Ответ от сервера: $jsonMap');

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
      // print('Произошла ошибка при входе: $e');
      // print('Стек вызовов: $stackTrace');
      return ApiResponse(success: false, message: 'Внутренняя ошибка: $e');
    }
  }

  Future<ApiResponse> updateUser(
    String userId,
    String login,
    String? password,
    String firstName,
    String lastName,
    String patronymic,
    String roles,
  ) async {
    final url = Uri.parse('${AppConstants.baseAPIUrl}users/update.php');

    final body = {
      'id': userId,
      'login': login,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'patronymic': patronymic,
      'roles': roles,
    };

    try {
      final response = await http.post(url, body: json.encode(body));
      final jsonMap = json.decode(response.body);
      return ApiResponse.fromJson(jsonMap);
    } catch (e) {
      return ApiResponse(success: false, message: 'Ошибка сети: $e');
    }
  }

  // Future<ApiResponse> loginUser(String email, String password) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('${AppConstants.baseAPIUrl}users/login.php'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: json.encode({'email': email, 'password': password}),
  //     );

  //     if (response.statusCode == 200) {
  //       final jsonMap = json.decode(response.body);
  //       print(jsonMap);
  //       return ApiResponse.fromJson(jsonMap);
  //     } else {
  //       return ApiResponse(success: false, message: 'Ошибка соединения с сервером');
  //     }
  //   } catch (e) {
  //     return ApiResponse(success: false, message: 'Ошибка: $e');
  //   }
  // }
  Future<ApiResponse> loginUser(String email, String password) async {
    try {
      // Проверка на валидность URL
      final url = Uri.tryParse('${AppConstants.baseAPIUrl}users/login.php');
      if (url == null) {
        return ApiResponse(success: false, message: 'Некорректный URL сервера');
      }

      // Заголовки запроса
      final headers = {'Content-Type': 'application/json'};

      // Тело запроса
      final body = json.encode({'email': email, 'password': password});

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

      // print('Ответ от сервера: $jsonMap');

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
      // print('Произошла ошибка при входе: $e');
      // print('Стек вызовов: $stackTrace');
      return ApiResponse(success: false, message: 'Внутренняя ошибка: $e');
    }
  }
}
