// lib/repositories/printer_ip_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventerization_4aas/constants/app_constants.dart';

class PrinterIpService {
  static const String _key = 'printer_ip'; // локальное хранилище

  /// Получает IP принтера: сначала из SharedPreferences, потом дефолт
  static Future<String> getPrinterIp() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    return saved ?? AppConstants.defaultPrinterIp; // ← см. ниже
  }

  /// Сохраняет IP принтера:
  /// 1. Отправляет на сервер (в PHP-скрипт)
  /// 2. Сохраняет локально
  static Future<void> savePrinterIp(String ip) async {
    // 1. Отправляем на сервер
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseAPIUrl}/save_printer_ip.php?printer_ip=$ip'),
      );

      if (response.statusCode != 200) {
        throw Exception('Сервер вернул ошибку: ${response.statusCode}');
      }
    } catch (e) {
      // Можно показать ошибку, но не останавливаем сохранение локально
      // print('Не удалось отправить IP на сервер: $e');
    }

    // 2. Сохраняем локально — чтобы работать оффлайн
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, ip);
  }
}