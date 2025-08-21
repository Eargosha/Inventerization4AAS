import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

// Модели
import 'package:inventerization_4aas/models/cabinet_model.dart'; // Убедись, что путь верный
import 'package:inventerization_4aas/models/api_response_model.dart';

// Репозитории
import 'package:inventerization_4aas/repositories/cabinet_repository.dart';

part 'cabinet_state.dart';

class CabinetCubit extends Cubit<CabinetState> {
  final CabinetRepository cabinetRepository;

  CabinetCubit({required this.cabinetRepository}) : super(CabinetInitial());

  Future<void> loadCabinets() async {
    emit(CabinetLoading());

    try {
      final ApiResponse response = await cabinetRepository.loadCabinets();

      if (response.success && response.data is List) {
        final List<Cabinet> cabinets =
            (response.data as List)
                .map((item) => Cabinet.fromJson(item as Map<String, dynamic>))
                .toList()
              ..sort((a, b) {
                final aNum = int.tryParse(a.name ?? '') ?? 0;
                final bNum = int.tryParse(b.name ?? '') ?? 0;
                return aNum.compareTo(bNum);
              });

        cabinets.add(Cabinet(name: 'Ремонт', cabinetFloor: '1', id: 87654432));

        emit(
          CabinetLoadSuccess(
            cabinets: cabinets,
            message: response.message ?? 'Список кабинетов загружен',
          ),
        );
      } else {
        emit(
          CabinetFailure(
            response.message ?? 'Не удалось загрузить список кабинетов',
          ),
        );
      }
    } catch (e) {
      emit(CabinetFailure('Ошибка сети: $e'));
    }
  }
}
