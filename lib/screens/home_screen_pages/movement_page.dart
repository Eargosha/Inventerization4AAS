import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventerization_4aas/cubit/transfer/transfer_counts_cubit.dart';
import 'package:inventerization_4aas/router/route.dart';
import 'package:inventerization_4aas/constants/theme/app_colors.dart';

class MovementScreen extends StatefulWidget {
  @override
  State<MovementScreen> createState() => _MovementScreenState();
}

class _MovementScreenState extends State<MovementScreen>
    with TickerProviderStateMixin {
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

  final List<int> availableYears = [
    DateTime.now().year - 2,
    DateTime.now().year - 1,
    DateTime.now().year,
  ];

  final int currentMonthIndex = DateTime.now().month - 1;

  late TabController _tabController;
  late ScrollController _scrollController;

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
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _tabController = TabController(
      initialIndex: 2,
      length: availableYears.length,
      vsync: this,
    );

    // Загружаем данные счётчиков
    Future.microtask(() {
      if (!mounted) return;
      context.read<TransferCountsCubit>().loadAllCounts(availableYears);
    });

    // Анимация скролла
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent + (currentMonthIndex * 46.0),
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransferCountsCubit, TransferCountsState>(
      builder: (context, state) {
        Map<int, Map<int, int>> counts = {};

        if (state is TransferCountsLoaded) {
          counts = state.countsByYearAndMonth;
        }
        // Для TransferCountsLoading и TransferCountsInitial показываем нули
        // Для TransferCountsFailure можно показать ошибку, но пока просто нули

        return Scaffold(
          body: Column(
            children: [
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: availableYears
                      .map((year) => Tab(text: "$year"))
                      .toList(),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: availableYears.map((year) {
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: months.length,
                      itemBuilder: (context, index) {
                        final monthName = months[index];
                        final monthNumber = _monthToNumber[monthName] ?? 1;
                        final count = counts[year]?[monthNumber] ?? 0;

                        final selectedDate = DateTime(year, monthNumber);
                        final now = DateTime.now();
                        final isFuture =
                            selectedDate.isAfter(now) &&
                            selectedDate.year >= now.year;

                        return ListTile(
                          onTap: isFuture
                              ? null
                              : () => _showMonthDetails(
                                  context,
                                  monthName,
                                  year,
                                ),
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
        );
      },
    );
  }
}