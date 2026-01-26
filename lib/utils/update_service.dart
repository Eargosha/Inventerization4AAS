import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:inventerization_4aas/models/update_info_model.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';



class UpdateService {
  static Future<void> downloadAndInstall(UpdateInfo info) async {
    print('===== НАЧАЛО ПРОЦЕССА ОБНОВЛЕНИЯ =====');
    print('[UpdateService] Получена информация об обновлении: $info');
    print('[UpdateService] Версия: ${info.version}');
    print('[UpdateService] URL/Путь: ${info.url}');
    print('[UpdateService] Изменения (changelog): ${info.changelog}');

    if (kIsWeb) {
      print('[UpdateService] Обновление на вебе не поддерживается. Прерываем.');
      return;
    }

    try {
      if (Platform.isWindows) {
        // Для Windows: проверяем, является ли путь UNC-путём (начинается с \\)
        if (info.url.startsWith(r'\\') || info.url.startsWith('\\\\')) {
          print('[UpdateService] Обнаружен UNC-путь Windows. Используем файловую систему напрямую.');
          await _installFromNetworkPath(info.url);
        } else {
          // Если это обычный HTTP URL
          print('[UpdateService] Обнаружен HTTP(S) URL. Используем http-загрузку.');
          final uri = Uri.parse(info.url);
          await _downloadAndInstallFromHttp(uri, info);
        }
      } else if (Platform.isAndroid) {
        // Для Android всегда используем HTTP
        print('[UpdateService] Платформа Android. Используем http-загрузку.');
        final uri = Uri.parse(info.url);
        await _downloadAndInstallFromHttp(uri, info);
      } else {
        print('[UpdateService] Неизвестная платформа: ${Platform.operatingSystem}. Установка невозможна.');
        throw Exception('Платформа не поддерживается для установки');
      }

      print('===== ОБНОВЛЕНИЕ ЗАВЕРШЕНО УСПЕШНО =====');
    } catch (e, stackTrace) {
      print('[UpdateService] КРИТИЧЕСКАЯ ОШИБКА ВО ВРЕМЯ ОБНОВЛЕНИЯ:');
      print('[UpdateService] Тип ошибки: ${e.runtimeType}');
      print('[UpdateService] Сообщение: $e');
      print('[UpdateService] Stack trace:\n$stackTrace');
      rethrow;
    }
  }

  /// Скачивает файл по HTTP и устанавливает
  static Future<void> _downloadAndInstallFromHttp(Uri uri, UpdateInfo info) async {
    print('[_downloadAndInstallFromHttp] Начало загрузки по HTTP: $uri');
    
    final fileName = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'update_file';
    print('[_downloadAndInstallFromHttp] Имя файла: $fileName');

    // 1. Скачиваем файл
    print('[_downloadAndInstallFromHttp] Отправка HTTP-запроса...');
    final response = await http.get(uri);
    print('[_downloadAndInstallFromHttp] Получен ответ. Код статуса: ${response.statusCode}');
    
    if (response.statusCode != 200) {
      final errorMsg = 'Не удалось скачать файл: ${response.statusCode} - ${response.reasonPhrase}';
      print('[_downloadAndInstallFromHttp] ОШИБКА СКАЧИВАНИЯ: $errorMsg');
      throw Exception(errorMsg);
    }

    print('[_downloadAndInstallFromHttp] Файл успешно загружен. Размер: ${response.bodyBytes.length} байт');

    // 2. Сохраняем во временную директорию
    print('[_downloadAndInstallFromHttp] Получение временной директории...');
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/$fileName';
    final file = File(filePath);
    print('[_downloadAndInstallFromHttp] Полный путь к файлу: $filePath');

    print('[_downloadAndInstallFromHttp] Сохранение файла на диск...');
    await file.writeAsBytes(response.bodyBytes);
    print('[_downloadAndInstallFromHttp] Файл успешно записан. Существует: ${await file.exists()}');
    print('[_downloadAndInstallFromHttp] Размер сохранённого файла: ${await file.length()} байт');

    // 3. Устанавливаем
    if (Platform.isAndroid) {
      print('[_downloadAndInstallFromHttp] Установка APK на Android...');
      await _installApk(file);
    } else if (Platform.isWindows) {
      print('[_downloadAndInstallFromHttp] Установка на Windows...');
      await _runWindowsInstaller(file);
    }
  }

  /// Устанавливает файл напрямую из UNC-пути Windows
  static Future<void> _installFromNetworkPath(String uncPath) async {
    print('[_installFromNetworkPath] Обработка UNC-пути: $uncPath');

    try {
      // Нормализуем путь: заменяем двойные обратные слеши на одинарные
      String normalizedPath = uncPath;
      if (uncPath.startsWith('\\\\\\\\')) {
        normalizedPath = uncPath.substring(2);
      } else if (uncPath.startsWith('\\\\')) {
        normalizedPath = uncPath;
      }

      print('[_installFromNetworkPath] Нормализованный путь: $normalizedPath');

      final sourceFile = File(normalizedPath);
      
      // Проверяем существование исходного файла
      print('[_installFromNetworkPath] Проверка существования исходного файла...');
      if (!await sourceFile.exists()) {
        throw Exception('Файл не найден по пути: $normalizedPath');
      }
      print('[_installFromNetworkPath] Исходный файл существует. Размер: ${await sourceFile.length()} байт');

      // Определяем имя файла
      final fileName = normalizedPath.split(r'\').last;
      print('[_installFromNetworkPath] Имя файла: $fileName');

      // Копируем во временную директорию
      final tempDir = await getTemporaryDirectory();
      final destPath = '${tempDir.path}/$fileName';
      final destFile = File(destPath);

      print('[_installFromNetworkPath] Копирование в: $destPath');
      await sourceFile.copy(destPath);
      print('[_installFromNetworkPath] Файл скопирован успешно');


      // Запускаем установщик
      await _runWindowsInstaller(destFile);
    } catch (e, stackTrace) {
      print('[_installFromNetworkPath] ОШИБКА:');
      print('Тип: ${e.runtimeType}');
      print('Сообщение: $e');
      print('Stack trace:\n$stackTrace');
      rethrow;
    }
  }

  static Future<void> _installApk(File file) async {
    print('[_installApk] Начало установки APK...');
    if (!Platform.isAndroid) {
      print('[_installApk] Предупреждение: вызов на не-Android платформе!');
      return;
    }

    try {
      print('[_installApk] Путь к APK: ${file.path}');
      print('[_installApk] Проверка существования файла перед установкой: ${await file.exists()}');
      
      // ИЗМЕНЕНО: OpenFilex вместо OpenFile
      
      final result = await OpenFilex.open(file.path);
      print('[_installApk] Результат OpenFilex.open: тип=${result.type}, сообщение=${result.message}');

      if (result.type != ResultType.done) {
        final errorMsg = 'Ошибка установки через OpenFilex: ${result.message}';
        print('[_installApk] ОШИБКА: $errorMsg');
        throw Exception(errorMsg);
      }

      print('[_installApk] Установка APK инициирована успешно');
    } catch (e, stackTrace) {
      print('[_installApk] ИСКЛЮЧЕНИЕ:');
      print('[_installApk] Тип: ${e.runtimeType}');
      print('[_installApk] Сообщение: $e');
      print('[_installApk] Stack trace:\n$stackTrace');
      throw Exception('Не удалось установить APK: $e');
    }
  }

  static Future<void> _runWindowsInstaller(File file) async {
    print('[_runWindowsInstaller] Начало запуска установщика Windows...');
    if (!Platform.isWindows) {
      print('[_runWindowsInstaller] Предупреждение: вызов на не-Windows платформе!');
      return;
    }

    try {
      print('[_runWindowsInstaller] Путь к установщику: ${file.path}');
      print('[_runWindowsInstaller] Рабочая директория: ${file.parent.path}');
      print('[_runWindowsInstaller] Проверка существования файла: ${await file.exists()}');
 

      // Попытка запуска
      print('[_runWindowsInstaller] Запуск процесса установщика...');
      final process = await Process.start(
        file.path,
        [],
        runInShell: true,
        workingDirectory: file.parent.path,
      );

      print('[_runWindowsInstaller] Процесс запущен. PID: ${process.pid}');
      
      // Не ждём завершения — сразу выходим из приложения
      print('[_runWindowsInstaller] Завершение текущего приложения через exit(0)...');
      exit(0);
    } catch (e, stackTrace) {
      print('[_runWindowsInstaller] ИСКЛЮЧЕНИЕ ПРИ ЗАПУСКЕ:');
      print('[_runWindowsInstaller] Тип: ${e.runtimeType}');
      print('[_runWindowsInstaller] Сообщение: $e');
      print('[_runWindowsInstaller] Stack trace:\n$stackTrace');
      throw Exception('Не удалось запустить установщик: $e');
    }
  }
}