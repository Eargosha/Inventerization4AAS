import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:inventerization_4aas/constants/theme/app_colors.dart';
import 'package:inventerization_4aas/cubit/cabinet/cabinet_cubit.dart';
import 'package:inventerization_4aas/cubit/transfer/transfer_cubit.dart';
import 'package:inventerization_4aas/router/route.dart';
import 'package:inventerization_4aas/screens/widgets/filter_date.dart';
import 'package:inventerization_4aas/screens/widgets/filter_dropdown.dart';
import 'package:inventerization_4aas/screens/widgets/input_field_widget.dart';
import 'package:inventerization_4aas/screens/widgets/main_button.dart';
import 'package:inventerization_4aas/screens/widgets/movement_tile.dart';
import 'package:inventerization_4aas/constants/theme/app_text_styles.dart';
import 'package:path_provider/path_provider.dart';

@RoutePage()
class MonthDetailScreen extends StatefulWidget {
  final String month;
  final String year;

  MonthDetailScreen({Key? key, required this.month, required this.year})
    : super(key: key);

  @override
  State<MonthDetailScreen> createState() => _MonthDetailScreenState();
}

class _MonthDetailScreenState extends State<MonthDetailScreen> {
  @override
  void initState() {
    super.initState();
    monthNumber = _monthToNumber[widget.month] ?? 1;
    context.read<TransferCubit>().loadTransfers({
      'month': monthNumber,
      'year': widget.year,
    });
  }

  int? dayPickedForExportToExcel;
  late int monthNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.month + ' ' + widget.year + ' г.'),
        scrolledUnderElevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              context.router.push(CreateMovementRoute());
            },
            icon: Icon(Icons.add),
            tooltip: 'Добавить перемещение',
          ),
          // IconButton(
          //   onPressed: () {

          //   },
          //   tooltip: 'Сделать отчет данного',
          //   icon: Icon(Icons.table_chart),
          // )
          // mainButton(onPressed: () {}, title: 'Отчет')
          TextButton(
            // onPressed: () {
            //   context.read<TransferCubit>().exportTransfersToExcel(
            //     month: monthNumber,
            //     year: int.tryParse(widget.year)!,
            //   );
            // },
            onPressed: () {
              _showExportOptions(context, monthNumber, widget.year);
            },
            child: Text(
              'Отчет',
              style: AppTextStyle.style16w600.copyWith(
                color: AppColor.textPrimary,
              ),
            ),
          ),
        ],
      ),
      body: buildMouth(context),
    );
  }

  void _showExportOptions(
    BuildContext context,
    int monthNumber,
    String yearStr,
  ) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Кнопка "За месяц"
                ListTile(
                  title: Text(
                    'Сформировать отчёт за месяц',
                    textAlign: TextAlign.center,
                    style: AppTextStyle.style16w600.copyWith(
                      color: AppColor.textPrimary,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context); // закрываем попап
                    context.read<TransferCubit>().exportTransfersToExcel(
                      month: monthNumber,
                      year: int.tryParse(yearStr)!,
                    );
                  },
                ),
                Divider(height: 1),
                // Кнопка "За дату"
                ListTile(
                  title: Text(
                    'Сформировать отчёт за дату',
                    textAlign: TextAlign.center,
                    style: AppTextStyle.style16w600.copyWith(
                      color: AppColor.textPrimary,
                    ),
                  ),
                  onTap: () async {
                    // Определяем границы месяца
                    final DateTime firstDate = DateTime(
                      int.parse(widget.year),
                      monthNumber,
                    );
                    final DateTime lastDate = DateTime(
                      int.parse(widget.year),
                      monthNumber + 1,
                    ).subtract(const Duration(days: 1));
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      firstDate: firstDate,
                      lastDate: lastDate,
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: ColorScheme.light(
                              primary: AppColor.accentColor,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    dayPickedForExportToExcel = picked!.day;

                    Navigator.pop(context); // закрываем попап
                    // Здесь можно открыть выбор даты или сразу вызвать экспорт за сегодня
                    context.read<TransferCubit>().exportDailyTransfersToExcel(
                      month: picked!.month,
                      year: picked.year,
                      day: picked.day,
                    );
                  },
                ),
                // Кнопка "Отмена"
                ListTile(
                  title: Text(
                    'Отмена',
                    textAlign: TextAlign.center,
                    style: AppTextStyle.style16w600.copyWith(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveExcelFile(List<int> bytes) async {
    if (Platform.isWindows) {
      await _saveExcelFileWindows(bytes);
    } else if (Platform.isAndroid) {
      await _saveExcelFileAndroid(bytes);
    } else {
      // Для других платформ можно добавить поддержку или показать ошибку
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Сохранение не поддерживается на этой платформе'),
        ),
      );
      // print('Платформа не поддерживается: ${Platform.operatingSystem}');
    }
  }

  // работает на Windows
  Future<void> _saveExcelFileWindows(List<int> bytes) async {
    try {
      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Сохранить отчет по инвентаризации',
        fileName: dayPickedForExportToExcel == null
            ? 'Отчет по инвентаризации 4ААС ${widget.month} ${widget.year}.xlsx'
            : 'Отчет по инвентаризации 4ААС $dayPickedForExportToExcel ${widget.month} ${widget.year}.xlsx',
      );

      if (savePath != null) {
        final file = File(savePath);
        await file.writeAsBytes(bytes);
        // print('Файл сохранен: $savePath');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Файл успешно сохранен')));
      }
    } catch (e) {
      // print('Ошибка сохранения файла: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка сохранения файла: $e')));
    }
  }

  // Работает на Андроид, ошибка на Win
  Future<void> _saveExcelFileAndroid(List<int> bytes) async {
    try {
      // Создаем временный файл
      final tempDir = await getTemporaryDirectory();
      final file =
          await File(
              dayPickedForExportToExcel == null
                  ? '${tempDir.path}/Отчет по инвентаризации 4ААС ${widget.month} ${widget.year}.xlsx'
                  : '${tempDir.path}/Отчет по инвентаризации 4ААС $dayPickedForExportToExcel ${widget.month} ${widget.year}.xlsx',
            )
            ..createSync(recursive: true)
            ..writeAsBytesSync(bytes);

      // Открываем диалог сохранения
      final params = SaveFileDialogParams(
        sourceFilePath: file.path,
        fileName: dayPickedForExportToExcel == null
            ? 'Отчет по инвентаризации 4ААС ${widget.month} ${widget.year}.xlsx'
            : 'Отчет по инвентаризации 4ААС $dayPickedForExportToExcel ${widget.month} ${widget.year}.xlsx',
      );

      final filePath = await FlutterFileDialog.saveFile(params: params);

      if (filePath != null) {
        // print('Файл сохранен: $filePath');
        // Показать уведомление об успешном сохранении
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Файл успешно сохранен')));
      }
    } catch (e) {
      // print('Ошибка сохранения файла: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка сохранения файла: $e')));
    }
  }

  final Map<String, int> _monthToNumber = {
    "Январь": 1,
    "Февраль": 2,
    "Март": 3,
    "Апрель": 4,
    "Май": 5,
    "Июнь": 6,
    "Июль": 7,
    "Август": 8,
    "Сентябрь": 9,
    "Октябрь": 10,
    "Ноябрь": 11,
    "Декабрь": 12,
  };

  Widget buildMouth(BuildContext context) {
    List<Widget> filters = [
      DateFilterButton(
        title: 'Дата',
        year: widget.year,
        month: monthNumber.toString(),
        onChanged: (date) {
          if (date != null) {
            // print('Выбранная дата: $date');
            context.read<TransferCubit>().loadTransfers({
              'month': monthNumber,
              'year': widget.year,
              'day': date.day,
            });
          }
        },
      ),
      SizedBox(width: 16),
      BlocBuilder<CabinetCubit, CabinetState>(
        builder: (context, cabinetState) {
          if (cabinetState is CabinetLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (cabinetState is CabinetLoadSuccess) {
            List<String> cabinetNames = cabinetState.cabinets
                .map((cabinet) => 'Из кабинета ${cabinet.name}')
                .toList();
            cabinetNames = ['Из кабинета'] + cabinetNames;

            return FilterDropdown(
              title: "Из кабинета",
              items: cabinetNames,
              onChanged: (selectedCabinet) {
                // Фильтруем только по выбранному кабинету
                if (selectedCabinet != null &&
                    selectedCabinet != 'Из кабинета') {
                  final cabinetNumber = selectedCabinet.replaceFirst(
                    'Из кабинета ',
                    '',
                  );
                  // print('[==+==] Выбрали $cabinetNumber');
                  context.read<TransferCubit>().loadTransfers({
                    'from_where': cabinetNumber,
                    'month': monthNumber,
                    'year': widget.year,
                  });
                } else {
                  // Если выбрано "Кабинет" — загружаем всё
                  context.read<TransferCubit>().loadTransfers({
                    'month': monthNumber,
                    'year': widget.year,
                  });
                }
              },
            );
          } else {
            return const Text('Ошибка загрузки кабинетов');
          }
        },
      ),
      SizedBox(width: 16),
      BlocBuilder<CabinetCubit, CabinetState>(
        builder: (context, cabinetState) {
          if (cabinetState is CabinetLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (cabinetState is CabinetLoadSuccess) {
            List<String> cabinetNames = cabinetState.cabinets
                .map((cabinet) => 'В кабинет ${cabinet.name}')
                .toList();
            cabinetNames = ['В кабинет'] + cabinetNames;

            return FilterDropdown(
              title: "Из кабинета",
              items: cabinetNames,
              onChanged: (selectedCabinet) {
                // Фильтруем только по выбранному кабинету
                if (selectedCabinet != null && selectedCabinet != 'В кабинет') {
                  final cabinetNumber = selectedCabinet.replaceFirst(
                    'В кабинет ',
                    '',
                  );
                  // print('[==+==] Выбрали $cabinetNumber');
                  context.read<TransferCubit>().loadTransfers({
                    'to_where': cabinetNumber,
                    'month': monthNumber,
                    'year': widget.year,
                  });
                } else {
                  // Если выбрано "Кабинет" — загружаем всё
                  context.read<TransferCubit>().loadTransfers({
                    'month': monthNumber,
                    'year': widget.year,
                  });
                }
              },
            );
          } else {
            return const Text('Ошибка загрузки кабинетов');
          }
        },
      ),
    ];

    return BlocConsumer<TransferCubit, TransferState>(
      listener: (context, state) {
        if (state is TransferExcelExported) {
          _saveExcelFile(state.fileBytes);
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            // Поисковое поле
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 22.0,
                vertical: 16,
              ),
              child: InputField(
                placeholder: 'Поиск по названию, номеру',
                obscureText: false,
                onChanged: (text) {
                  // Фильтруем по inventory_item и name
                  if (text!.isNotEmpty) {
                    context.read<TransferCubit>().loadTransfers({
                      'inventory_item': text,
                      'name': text,
                      'search_mode': 'or',
                      'month': monthNumber,
                      'year': widget.year,
                    });
                  } else {
                    context.read<TransferCubit>().loadTransfers({
                      'month': monthNumber,
                      'year': widget.year,
                    });
                  }
                },
                search: true,
              ),
            ),

            // Фильтры
            Container(
              height: 35,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: filters,
                padding: EdgeInsets.only(left: 10, right: 10),
              ),
            ),

            // Список перемещений
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 16,
                ),
                child: state is TransferLoadSuccess
                    ? state.transfers.length != 0
                          ? ListView.builder(
                              itemCount: state.transfers.length,
                              itemBuilder: (context, index) {
                                final transfer = state.transfers[index];

                                return Column(
                                  children: [
                                    movementTile(
                                      name: transfer.name ?? '',
                                      fromPlace: transfer.fromWhere ?? '',
                                      toPlace: transfer.toWhere ?? '',
                                      invNumber: transfer.inventoryItem ?? '',
                                      date:
                                          DateTime.tryParse(
                                            transfer.date ?? '',
                                          ) ??
                                          DateTime.now(),
                                      onTap: () {
                                        context.router.push(
                                          MovementObjectRoute(
                                            transfer: transfer,
                                          ),
                                        );
                                      },
                                    ),
                                    Divider(),
                                  ],
                                );
                              },
                            )
                          : Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Нет данных, попробуйте',
                                      style: AppTextStyle.style20w400,
                                    ),
                                    mainButton(
                                      onPressed: () {
                                        context
                                            .read<TransferCubit>()
                                            .loadTransfers({
                                              'month': monthNumber,
                                              'year': widget.year,
                                            });
                                      },
                                      title: 'Обновить',
                                      icon: Icon(Icons.repeat, color: AppColor.textInverse),
                                    ),
                                  ],
                                ),
                              ),
                            )
                    : state is TransferLoading
                    ? Center(child: CircularProgressIndicator())
                    : state is TransferFailure
                    ? Center(child: Text(state.message))
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Данное состояние не обработано, попробуйте',
                                style: AppTextStyle.style16w600,
                              ),
                              mainButton(
                                onPressed: () {
                                  context.read<TransferCubit>().loadTransfers({
                                    'month': monthNumber,
                                    'year': widget.year,
                                  });
                                },
                                title: 'Обновить',
                                icon: Icon(Icons.repeat, color: AppColor.textInverse),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
