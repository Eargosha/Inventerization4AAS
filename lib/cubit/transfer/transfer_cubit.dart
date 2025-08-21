import 'package:excel/excel.dart';
import 'package:flutter/material.dart' hide Border, BorderStyle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:inventerization_4aas/models/transfer_model.dart';
import 'package:inventerization_4aas/models/api_response_model.dart';
import 'package:inventerization_4aas/repositories/transfer_repository.dart';

part 'transfer_state.dart';

class TransferCubit extends Cubit<TransferState> {
  final TransferRepository transferRepository;

  // Храним данные в формате { год: { месяц: кол-во } }
  final Map<int, Map<int, int>> countsByYearAndMonth = {};

  TransferCubit({required this.transferRepository}) : super(TransferInitial());

  void updateMonthCount(int year, int month, int count) {
    // Добавляем год, если его нет
    countsByYearAndMonth.putIfAbsent(year, () => {});

    // Обновляем значение
    countsByYearAndMonth[year]![month] = count;

    // Выбрасываем событие
    emit(TransferMonthCountUpdated(month: month, year: year, count: count));
  }

  Future<void> createTransfer(Transfer transfer) async {
    emit(TransferLoading());

    try {
      final ApiResponse response = await transferRepository.createTransfer(
        transfer,
      );

      if (response.success) {
        final int newId = int.tryParse(response.data['id'].toString()) ?? 0;
        final Transfer newTransfer = transfer.copyWith(id: newId);
        emit(
          TransferCreateSuccess(
            message: response.message ?? 'Перемещение создано',
            newTransfer,
          ),
        );
      } else {
        emit(TransferFailure('Ошибка создания: ${response.message}'));
      }
    } catch (e) {
      emit(TransferFailure('Ошибка сети: $e'));
    }
  }

  Future<void> getTransfersCountByMonthAndYear(int month, int year) async {
    emit(TransferLoading());

    try {
      final ApiResponse response = await transferRepository
          .getTransfersCountByMonthAndYear(month, year);

      if (response.success) {
        final int count = int.tryParse(response.data.toString()) ?? 0;
        // print(
        //   '[==+==] Итак, в $month месяце $year года получается $count записей',
        // );

        // ✅ Правильное обновление
        updateMonthCount(
          year,
          month,
          count,
        ); // <-- Вот здесь важно: year, month
      } else {
        emit(TransferFailure(response.message ?? 'Ошибка загрузки данных'));
      }
    } catch (e) {
      emit(TransferFailure('Ошибка сети: $e'));
    }
  }

  Future<void> updateTransfer(Transfer transfer) async {
    emit(TransferLoading());

    try {
      final ApiResponse response = await transferRepository.updateTransfer(
        transfer,
      );

      if (response.success) {
        emit(
          TransferUpdateSuccess(
            message: response.message ?? 'Перемещение обновлено',
            transfer,
          ),
        );
      } else {
        emit(TransferFailure('Ошибка обновления: ${response.message}'));
      }
    } catch (e) {
      emit(TransferFailure('Ошибка сети: $e'));
    }
  }

  Future<void> deleteTransfer(int id) async {
    emit(TransferLoading());

    try {
      final ApiResponse response = await transferRepository.deleteTransfer(id);

      if (response.success) {
        emit(
          TransferDeleteSuccess(
            message: response.message ?? 'Перемещение удалено',
            id: id,
          ),
        );
      } else {
        emit(TransferFailure('Ошибка удаления: ${response.message}'));
      }
    } catch (e) {
      emit(TransferFailure('Ошибка сети: $e'));
    }
  }

  Future<void> loadTransfers(Map<String, dynamic> filters) async {
    emit(TransferLoading());

    try {
      final ApiResponse response = await transferRepository.loadTransfers(
        filters,
      );

      if (response.success) {
        final List<dynamic> dataList = response.data as List;
        final List<Transfer> transfers = dataList
            .map((item) => Transfer.fromJson(item))
            .toList();

        print(
          "[==+==] !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Transfers загружены",
        );
        print(transfers);
        transfers.forEach(
          (element) => print(element.id.toString() + "  ___   "),
        );

        emit(
          TransferLoadSuccess(
            transfers: transfers,
            message: response.message ?? '',
          ),
        );
      } else {
        emit(
          TransferFailure(
            response.message ?? 'Не удалось загрузить список перемещений',
          ),
        );
      }
    } catch (e) {
      emit(TransferFailure('Ошибка сети: $e'));
    }
  }

  Future<Transfer?> getLastTransfer(String inventoryItem) async {
    emit(TransferLoading());

    try {
      final ApiResponse response = await transferRepository
          .getLastTransferByInventoryItem(inventoryItem);

      if (response.success && response.data != null) {
        final transfer = Transfer.fromJson(
          response.data as Map<String, dynamic>,
        );
        emit(TransferLastFound(transfer));
        return transfer; // Возвращаем объект, если нужно использовать в UI
      } else {
        emit(
          TransferFailure(response.message ?? 'Не удалось найти перемещение'),
        );
        return null;
      }
    } catch (e) {
      emit(TransferFailure('Ошибка сети: $e'));
      return null;
    }
  }

  Future<List<int>?> _generateExcelReport({
    required int month,
    required int year,
    required List<Transfer> transfers,
  }) async {
    final excel = Excel.createExcel();

    // Получаем автоматически созданный лист Sheet1
    final sheet = excel['Sheet1'];

    initializeDateFormatting('ru_RU', null);

    // Создаем стили
    final headerStyle = CellStyle(
      fontFamily: 'Times New Roman',
      fontSize: 16,
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      textWrapping: TextWrapping.WrapText,
      topBorder: Border(borderStyle: BorderStyle.Thin),
      bottomBorder: Border(borderStyle: BorderStyle.Thin),
      leftBorder: Border(borderStyle: BorderStyle.Thin),
      rightBorder: Border(borderStyle: BorderStyle.Thin),
    );

    final dataStyle = CellStyle(
      fontFamily: 'Times New Roman',
      fontSize: 14,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      textWrapping: TextWrapping.WrapText,
      topBorder: Border(borderStyle: BorderStyle.Thin),
      bottomBorder: Border(borderStyle: BorderStyle.Thin),
      leftBorder: Border(borderStyle: BorderStyle.Thin),
      rightBorder: Border(borderStyle: BorderStyle.Thin),
      numberFormat: NumFormat.standard_49,
    );

    final titleStyle = CellStyle(
      fontFamily: 'Times New Roman',
      fontSize: 16,
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      textWrapping: TextWrapping.WrapText,
      topBorder: Border(borderStyle: BorderStyle.Thin),
      bottomBorder: Border(borderStyle: BorderStyle.Thin),
      leftBorder: Border(borderStyle: BorderStyle.Thin),
      rightBorder: Border(borderStyle: BorderStyle.Thin),
    );

    // Установим заголовок отчёта
    final title =
        'Переносы техники ${DateFormat('MMMM yyyy', 'ru_RU').format(DateTime(year, month))} г.';

    // Объединяем A1:G1 и устанавливаем заголовок
    sheet.merge(
      CellIndex.indexByString('A1'),
      CellIndex.indexByString('G1'),
      customValue: TextCellValue(title),
    );

    // Применяем стиль к заголовку отчёта
    sheet.cell(CellIndex.indexByString('A1')).cellStyle = titleStyle;
    sheet.setRowHeight(0, 60);

    // Заголовки колонок (строка 2, индекс 1)
    final headers = [
      '№ п/п',
      'Дата',
      'Наименование техники',
      'Инв. №',
      'Откуда',
      'Куда',
      'Причина',
    ];

    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(rowIndex: 1, columnIndex: i),
      );
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    // Заполнение данными (начиная со строки 3, индекс 2)
    for (int i = 0; i < transfers.length; i++) {
      final transfer = transfers[i];
      final row = i + 2; // строка 3 и далее

      // № п/п
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        ..value = TextCellValue((i + 1).toString())
        ..cellStyle = dataStyle;

      // Дата
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        ..value = TextCellValue(transfer.date ?? '')
        ..cellStyle = dataStyle;

      // Наименование техники
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
        ..value = TextCellValue(transfer.name ?? '')
        ..cellStyle = dataStyle;

      // Инв. №
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
        ..value = TextCellValue(transfer.inventoryItem ?? '')
        ..cellStyle = dataStyle;

      // Откуда
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
        ..value = TextCellValue(transfer.fromWhere ?? '')
        ..cellStyle = dataStyle;

      // Куда
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
        ..value = TextCellValue(transfer.toWhere ?? '')
        ..cellStyle = dataStyle;

      // Причина
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
        ..value = TextCellValue(transfer.reason ?? '')
        ..cellStyle = dataStyle;
    }

    // Автоподстройка ширины столбцов
    sheet.setDefaultColumnWidth(20);

    // Устанавливаем высоту строк
    sheet.setDefaultRowHeight(30);

    // Сохраняем и возвращаем байты
    return excel.save();
  }

  // Future<List<int>?> _generateExcelReport({
  //   required int month,
  //   required int year,
  //   required List<Transfer> transfers,
  // }) async {
  //   final excel = Excel.createExcel();

  //   // Получаем автоматически созданный лист Sheet1
  //   final sheet = excel['Sheet1'];

  //   initializeDateFormatting('ru_RU', null);

  //   // Установим заголовок отчёта
  //   final title =
  //       'Переносы техники ${DateFormat('MMMM yyyy', 'ru_RU').format(DateTime(year, month))} г.';

  //   // Объединяем A1:G1 и устанавливаем заголовок
  //   sheet.merge(
  //     CellIndex.indexByString('A1'),
  //     CellIndex.indexByString('G1'),
  //     customValue: TextCellValue(title),
  //   );

  //   // Стиль для заголовка отчёта
  //   sheet.cell(CellIndex.indexByString('A1')).cellStyle = CellStyle(
  //     bold: true,
  //     horizontalAlign: HorizontalAlign.Center,
  //   );

  //   // Заголовки колонок (строка 2, индекс 1)
  //   final headers = [
  //     '№ п/п',
  //     'Дата',
  //     'Наименование техники',
  //     'Инв. №',
  //     'Откуда',
  //     'Куда',
  //     'Причина',
  //   ];

  //   for (int i = 0; i < headers.length; i++) {
  //     final cell = sheet.cell(
  //       CellIndex.indexByColumnRow(rowIndex: 1, columnIndex: i),
  //     );
  //     cell.value = TextCellValue(headers[i]);
  //     cell.cellStyle = CellStyle(bold: true);
  //   }

  //   // Заполнение данными (начиная со строки 3, индекс 2)
  //   for (int i = 0; i < transfers.length; i++) {
  //     final transfer = transfers[i];
  //     final row = i + 2; // строка 3 и далее

  //     sheet
  //         .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
  //         .value = TextCellValue(
  //       (i + 1).toString(),
  //     );

  //     sheet
  //         .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
  //         .value = TextCellValue(
  //       transfer.date ?? '',
  //     );

  //     sheet
  //         .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
  //         .value = TextCellValue(
  //       transfer.name ?? '',
  //     );

  //     sheet
  //         .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
  //         .value = TextCellValue(
  //       transfer.inventoryItem ?? '',
  //     );

  //     sheet
  //         .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
  //         .value = TextCellValue(
  //       transfer.fromWhere ?? '',
  //     );

  //     sheet
  //         .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
  //         .value = TextCellValue(
  //       transfer.toWhere ?? '',
  //     );

  //     sheet
  //         .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
  //         .value = TextCellValue(
  //       transfer.reason ?? '',
  //     );
  //   }

  //   // Автоподстройка ширины столбцов
  //   for (int col = 0; col <= 6; col++) {
  //     sheet.setDefaultColumnWidth(15);
  //   }

  //   // Сохраняем и возвращаем байты
  //   return excel.save();
  // }

  Future<void> exportTransfersToExcel({
    required int month,
    required int year,
  }) async {
    emit(TransferLoading());

    try {
      final ApiResponse response = await transferRepository.loadTransfers({
        'month': month,
        'year': year,
      });

      if (response.success) {
        final List<dynamic> dataList = response.data as List;
        final List<Transfer> transfers = dataList
            .map((item) => Transfer.fromJson(item))
            .toList();

        final List<int>? fileBytes = await _generateExcelReport(
          month: month,
          year: year,
          transfers: transfers,
        );

        if (fileBytes != null) {
          emit(TransferExcelExported(fileBytes));
        } else {
          emit(TransferFailure('Ошибка генерации файла'));
        }
      } else {
        emit(
          TransferFailure(response.message ?? 'Не удалось загрузить данные'),
        );
      }
    } catch (e) {
      emit(TransferFailure('Ошибка сети: $e'));
    }
  }
}
