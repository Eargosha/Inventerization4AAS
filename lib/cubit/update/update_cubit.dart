import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventerization_4aas/models/update_info_model.dart';
import 'package:inventerization_4aas/repositories/update_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';

part 'update_state.dart';

class UpdateCubit extends Cubit<UpdateState> {
  final UpdateRepository _repository;

  UpdateCubit({required UpdateRepository repository})
    : _repository = repository,
      super(UpdateInitial());

  Future<void> checkForUpdate() async {
    emit(UpdateChecking());

    try {
      // Определяем платформу
      String platform;
      if (kIsWeb) {
        return; // не поддерживаем
      } else if (Platform.isAndroid) {
        platform = 'android';
      } else if (Platform.isWindows) {
        platform = 'windows';
      } else {
        emit(UpdateError('Платформа не поддерживается'));
        return;
      }

      // Получаем текущую версию
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersionStr = packageInfo.version;
      final currentVersion = Version.parse(currentVersionStr);

      // Получаем последнюю версию с сервера
      final latest = await _repository.fetchLatestVersion(platform);
      if (latest == null) {
        emit(UpdateError('Не удалось загрузить информацию об обновлении'));
        return;
      }

      final latestVersion = Version.parse(latest.version);

      if (latestVersion > currentVersion) {
        emit(UpdateAvailable(latest));
      } else {
        emit(UpdateNotNeeded());
      }
    } catch (e) {
      emit(UpdateError('Ошибка проверки обновления: ${e.toString()}'));
    }
  }
}
