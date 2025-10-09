import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

// Модели
import 'package:inventerization_4aas/models/api_response_model.dart';
import 'package:inventerization_4aas/models/product_model.dart';
import 'package:inventerization_4aas/repositories/printer_status_repository.dart';

part 'printer_state.dart';

class PrinterStatusCubit extends Cubit<PrinterStatusState> {
  final PrinterStatusRepository printerStatusRepository;
  late Timer _statusUpdateTimer;

  PrinterStatusCubit({required this.printerStatusRepository})
    : super(PrinterStatusInitial()) {
    // Запускаем таймер при создании кубита
    _startStatusUpdateTimer();
  }

  void _startStatusUpdateTimer() {
    _statusUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      getPrinterNetworkStatus();
    });
  }

  @override
  Future<void> close() {
    _statusUpdateTimer.cancel(); // Останавливаем таймер при закрытии
    return super.close();
  }

  /// Получает сетевой статус принтера (ONLINE/OFFLINE)
  Future<bool> getPrinterNetworkStatus() async {
    emit(PrinterNetworkStatusLoading());

    try {
      final ApiResponse response = await printerStatusRepository
          .getPrinterStatus();

      if (response.success) {
        final String? status =
            response.message; // "ONLINE", "OFFLINE", "UNKNOWN"

        print("Получили такой статус принтера $status");

        final bool isOnline = status == "ONLINE";

        print(
          "[==+==] Сетевой статус принтера - $isOnline (сырой статус: $status)",
        );

        emit(
          PrinterNetworkStatusLoadSuccess(
            isOnline: isOnline,
            message: response.message ?? 'Статус успешно получен',
          ),
        );

        return isOnline;
      } else {
        final failureState = PrinterNetworkStatusFailure(
          response.message ?? 'Не удалось узнать сетевой статус принтера',
        );
        emit(failureState);
        return false;
      }
    } catch (e, stackTrace) {
      print('Ошибка при получении сетевого статуса: $e');
      print('Стек вызовов: $stackTrace');

      final failureState = PrinterNetworkStatusFailure('Ошибка сети: $e');
      emit(failureState);
      return false;
    }
  }

  /// Конфигурирует принтер с тонкой настройкой параметров
  Future<void> configurePrinter({
    required double labelLength,
    required double labelWidth,
    required bool isFrontAntenna,
    required double antennaX,
    required double antennaY,
    required double powerWrite,
    required double powerRead,
    required double pitchSize,
  }) async {
    emit(PrinterConfiguring());

    try {
      final ApiResponse response = await printerStatusRepository
          .configurePrinter(
            labelLength: labelLength,
            labelWidth: labelWidth,
            isFrontAntenna: isFrontAntenna,
            antennaX: antennaX,
            antennaY: antennaY,
            powerWrite: powerWrite,
            powerRead: powerRead,
            pitchSize: pitchSize,
          );

      if (response.success) {
        emit(
          PrinterConfigurationSuccess(
            message:
                response.message ?? 'Конфигурация принтера применена успешно',
          ),
        );
      } else {
        emit(
          PrinterConfigurationFailure(
            response.message ?? 'Не удалось применить конфигурацию',
          ),
        );
      }
    } catch (e, stackTrace) {
      print('Ошибка при конфигурации принтера: $e');
      print('Стек вызовов: $stackTrace');
      emit(PrinterConfigurationFailure('Ошибка сети: $e'));
    }
  }

  /// Отправляет задание на печать этикетки
  Future<void> printLabel(Product productToPrint, int labelType) async {
    emit(PrinterLabelPrinting());

    try {
      final ApiResponse response = await printerStatusRepository.printLabel(
        name: productToPrint.name!,
        productId: productToPrint.productId!,
        barcode: productToPrint.barcode!,
        rfid: productToPrint.rfid!,
        labelType: labelType,
      );

      if (response.success) {
        emit(
          PrinterLabelPrintSuccess(
            message: response.message ?? 'Задание на печать отправлено успешно',
          ),
        );
      } else if (response.message!.contains('Сервер вернул недопустимый')) {
        emit(
          PrinterLabelPrintAttention(
            message: response.message ?? 'Печать успешна, но есть ошибки',
          ),
        );
      }
      
       else {
        emit(
          PrinterLabelPrintFailure(
            response.message ?? 'Не удалось отправить задание на печать',
          ),
        );
      }
    } catch (e, stackTrace) {
      print('Ошибка при отправке задания на печать: $e');
      print('Стек вызовов: $stackTrace');

      emit(PrinterLabelPrintFailure('Ошибка сети: $e'));
    }
  }
}
