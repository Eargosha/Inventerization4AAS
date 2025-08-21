// services/network_checker.dart

import 'package:inventerization_4aas/constants/app_constants.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:http/http.dart' as http;

class NetworkChecker {
  // Диапазон подсети
  static const String ipPrefix = '10.104.';
  static const Duration timeout = Duration(seconds: 5);

  final NetworkInfo _networkInfo = NetworkInfo();

  /// Проверяет, находится ли устройство в нужной подсети
  Future<bool> isDeviceInCorrectSubnet() async {
    try {
      final ip = await _networkInfo.getWifiIP(); // Работает и на Wi-Fi, и на Ethernet
      print('Текущий IP устройства: $ip');

      if (ip == null || ip.isEmpty) {
        return false;
      }

      return ip.startsWith(ipPrefix);
    } catch (e) {
      print('Ошибка при получении IP: $e');
      return false;
    }
  }

  /// Проверяет, доступен ли сервер (опционально, но надёжнее)
  Future<bool> isServerReachable() async {
    try {
      final response = await http.get(Uri.parse('${AppConstants.baseAPIUrl}/ping.php'))
          .timeout(timeout);

      print('Ответ от сервера: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Сервер недоступен: $e');
      return false;
    }
  }

  /// Полная проверка: подсеть + доступность сервера
  Future<bool> isNetworkValid() async {
    final reachable = await isServerReachable();
    if (!reachable) {
      print('❌ Сервер ${AppConstants.baseAPIUrl} недоступен');
      return false;
    }

    final inSubnet = await isDeviceInCorrectSubnet();
    if (!inSubnet && !reachable) {
      print('❌ Устройство не в подсети $ipPrefix');
      return false;
    }

    print('✅ Устройство в нужной подсети и сервер доступен');
    return true;
  }
}