import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventerization_4aas/cubit/transfer/transfer_cubit.dart';
import 'package:inventerization_4aas/router/route.dart';
import 'package:inventerization_4aas/constants/theme/app_colors.dart';

class MovementScreen extends StatelessWidget {
  final int currentYear = DateTime.now().year;

  final List<String> months = [
    "Январь",
    "Февраль",
    "Март",
    "Апрель",
    "Май",
    "Июнь",
    "Июль",
    "Август",
    "Сентябрь",
    "Октябрь",
    "Ноябрь",
    "Декабрь",
  ];

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

  void _showMonthDetails(BuildContext context, String month, int year) {
    final monthNumber = _monthToNumber[month] ?? 1;
    final selectedDate = DateTime(year, monthNumber);
    final now = DateTime.now();

    if (selectedDate.isAfter(now) && selectedDate.year >= now.year) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Нельзя открыть данные из будущего')),
      );
      return;
    }

    context.router.push(MonthDetailRoute(month: month, year: year.toString()));
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TransferCubit>(); // можно и без read, но для вызова один раз — ок
    final List<int> availableYears = [currentYear - 2, currentYear - 1, currentYear];

    // Запрашиваем данные для всех месяцев и годов при первом открытии
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var year in availableYears) {
        for (var monthName in months) {
          final monthNumber = _monthToNumber[monthName] ?? 1;
          cubit.getTransfersCountByMonthAndYear(monthNumber, year);
        }
      }
    });

    return BlocBuilder<TransferCubit, TransferState>(
      builder: (context, state) {
        // Получаем данные из кубита
        final counts = cubit.countsByYearAndMonth;

        return DefaultTabController(
          length: availableYears.length,
          child: Scaffold(
            body: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: TabBar(
                    isScrollable: true,
                    tabs: availableYears.map((year) => Tab(text: "$year")).toList(),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: availableYears.map((year) {
                      return ListView.builder(
                        itemCount: months.length,
                        itemBuilder: (context, index) {
                          final monthName = months[index];
                          final monthNumber = _monthToNumber[monthName] ?? 1;

                          // Получаем количество записей
                          final count = counts[year]?[monthNumber] ?? 0;

                          // Проверка на будущее
                          final selectedDate = DateTime(year, monthNumber);
                          final now = DateTime.now();
                          final isFuture = selectedDate.isAfter(now) && selectedDate.year >= now.year;

                          return ListTile(
                            onTap: isFuture
                                ? null
                                : () => _showMonthDetails(context, monthName, year),
                            leading: Container(
                              decoration: BoxDecoration(
                                color: AppColor.elementColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.calendar_today),
                              ),
                            ),
                            title: Text(monthName),
                            trailing: Text('$count'),
                            enabled: !isFuture,
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}