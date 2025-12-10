import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

@RoutePage()
class MovementsHistoryScreen extends StatefulWidget {
  const MovementsHistoryScreen({Key? key}) : super(key: key);

  @override
  State<MovementsHistoryScreen> createState() => _MovementsHistoryScreenState();
}

class _MovementsHistoryScreenState extends State<MovementsHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TransferCubit>().loadTransfers({
      'order_by_date_desc': true,
    }); // Загружаем ВСЮ историю
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('История перемещений'),
      //   scrolledUnderElevation: 0,
      //   centerTitle: true,
      //   actions: [
      //     TextButton(
      //       onPressed: () {
      //         // Пустая функция как по требованию
      //       },
      //       child: Text(
      //         'Детально',
      //         style: AppTextStyle.style16w600.copyWith(
      //           color: AppColor.textPrimary,
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
      body: buildHistory(context),
    );
  }

  Widget buildHistory(BuildContext context) {
    List<Widget> filters = [
      DateFilterButton(
        title: 'Дата',
        onChanged: (date) {
          if (date != null) {
            print('Выбранная дата: $date');
            context.read<TransferCubit>().loadTransfers({
              'month': date.month,
              'year': date.year,
              'day': date.day,
              'order_by_date_desc': true,
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
            List<String> cabinetNames =
                ['Из кабинета'] +
                cabinetState.cabinets
                    .map((cabinet) => 'Из кабинета ${cabinet.name}')
                    .toList();

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
                  print('[==+==] Выбрали $cabinetNumber');
                  context.read<TransferCubit>().loadTransfers({
                    'from_where': cabinetNumber,
                    'order_by_date_desc': true,
                  });
                } else {
                  context.read<TransferCubit>().loadTransfers({
                    'order_by_date_desc': true,
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
            List<String> cabinetNames =
                ['В кабинет'] +
                cabinetState.cabinets
                    .map((cabinet) => 'В кабинет ${cabinet.name}')
                    .toList();

            return FilterDropdown(
              title: "В кабинет",
              items: cabinetNames,
              onChanged: (selectedCabinet) {
                if (selectedCabinet != null && selectedCabinet != 'В кабинет') {
                  final cabinetNumber = selectedCabinet.replaceFirst(
                    'В кабинет ',
                    '',
                  );
                  print('[==+==] Выбрали $cabinetNumber');
                  context.read<TransferCubit>().loadTransfers({
                    'to_where': cabinetNumber,
                    'order_by_date_desc': true,
                  });
                } else {
                  context.read<TransferCubit>().loadTransfers({
                    'order_by_date_desc': true,
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

    return BlocBuilder<TransferCubit, TransferState>(
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
                      'order_by_date_desc': true,
                    });
                  } else {
                    context.read<TransferCubit>().loadTransfers({
                      'order_by_date_desc': true,
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
                    ? (state.transfers.isNotEmpty
                          ? ListView.builder(
                              itemCount: state.transfers.length,
                              itemBuilder: (context, index) {
                                final transfer = state.transfers[index];
                                final currentDate =
                                    DateTime.tryParse(transfer.date ?? '') ??
                                    DateTime.now();
                                final currentDateString =
                                    "${currentDate.day}.${currentDate.month}.${currentDate.year}";

                                // Проверяем, нужно ли показывать заголовок даты
                                bool showDateHeader = true;
                                if (index > 0) {
                                  final prevTransfer =
                                      state.transfers[index - 1];
                                  final prevDate =
                                      DateTime.tryParse(
                                        prevTransfer.date ?? '',
                                      ) ??
                                      DateTime.now();
                                  final prevDateString =
                                      "${prevDate.day}.${prevDate.month}.${prevDate.year}";
                                  showDateHeader =
                                      currentDateString != prevDateString;
                                }

                                return Column(
                                  children: [
                                    if (showDateHeader)
                                      DateHeaderTile(
                                        dateText: currentDateString,
                                      ),

                                    movementTile(
                                      name: transfer.name ?? '',
                                      fromPlace: transfer.fromWhere ?? '',
                                      toPlace: transfer.toWhere ?? '',
                                      invNumber: transfer.inventoryItem ?? '',
                                      date: currentDate,
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
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
                                              'order_by_date_desc': true,
                                            });
                                      },
                                      title: 'Обновить',
                                      icon: Icon(
                                        Icons.repeat,
                                        color: AppColor.textInverse,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ))
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
                                    'order_by_date_desc': true,
                                  });
                                },
                                title: 'Обновить',
                                icon: Icon(
                                  Icons.repeat,
                                  color: AppColor.textInverse,
                                ),
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

class DateHeaderTile extends StatelessWidget {
  final String dateText;

  const DateHeaderTile({Key? key, required this.dateText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColor.secondButton,
      child: Text(
        dateText,
        style: AppTextStyle.style16w600.copyWith(color: AppColor.textPrimary),
      ),
    );
  }
}
