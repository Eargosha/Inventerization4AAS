import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventerization_4aas/models/api_response_model.dart';
import 'package:inventerization_4aas/repositories/transfer_repository.dart';

part 'transfer_counts_state.dart';

class TransferCountsCubit extends Cubit<TransferCountsState> {
  final TransferRepository transferRepository;

  TransferCountsCubit({required this.transferRepository}) : super(TransferCountsInitial());

  Future<void> loadAllCounts(List<int> years) async {
    emit(TransferCountsLoading());

    final Map<int, Map<int, int>> newCounts = {};
    String? globalError;

    for (final year in years) {
      newCounts[year] = {};
      for (int month = 1; month <= 12; month++) {
        try {
          final ApiResponse response = await transferRepository.getTransfersCountByMonthAndYear(month, year);
          if (response.success) {
            final count = int.tryParse(response.data.toString()) ?? 0;
            newCounts[year]![month] = count;
          } else {
            globalError ??= response.message;
          }
        } catch (e) {
          globalError ??= 'Ошибка сети: $e';
        }
      }
    }

    if (globalError != null) {
      emit(TransferCountsFailure(globalError));
    } else {
      emit(TransferCountsLoaded(newCounts));
    }
  }
}