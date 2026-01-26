import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventerization_4aas/cubit/notification/notification_cubit.dart';
import 'package:inventerization_4aas/cubit/update/update_cubit.dart';
import 'package:inventerization_4aas/router/route.dart';
import 'package:inventerization_4aas/screens/home_screen_pages/movements_history_page.dart';
import 'package:inventerization_4aas/screens/home_screen_pages/printer_page.dart';
import 'package:inventerization_4aas/screens/home_screen_pages/profile_page.dart';
import 'package:inventerization_4aas/screens/home_screen_pages/scan_page.dart';
import 'package:inventerization_4aas/screens/widgets/app_bar.dart';
import 'package:inventerization_4aas/constants/theme/app_colors.dart';
import 'package:inventerization_4aas/constants/theme/app_text_styles.dart';
import 'package:inventerization_4aas/utils/update_dialog_helper.dart';

@RoutePage()
class MainScreen extends StatefulWidget {
  MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1;
  late PageController _pageController;
  bool _isWindows = false;

  @override
  void initState() {
    super.initState();
    _isWindows = !kIsWeb && Platform.isWindows;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.linear,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Исправить ошибку при выводе отчета на Widows

  @override
  Widget build(BuildContext context) {
    // Массивы страниц и элементов навигации в зависимости от платформы
    List<Widget> allPages = _isWindows
        ? [
            // Для Windows убираем страницу сканирования
            PrinterScreen(),
            MovementsHistoryScreen(),
            ProfileScreen(),
          ]
        : [
            // Для других платформ оставляем все страницы
            PrinterScreen(),
            ScanScreen(),
            MovementsHistoryScreen(),
            ProfileScreen(),
          ];

    List<BottomNavigationBarItem> bottomNavItems = _isWindows
        ? [
            // Для Windows убираем пункт сканирования
            BottomNavigationBarItem(icon: Icon(Icons.print), label: "Печать"),
            BottomNavigationBarItem(
              icon: Icon(Icons.fire_truck),
              label: "Перемещения",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: "Профиль",
            ),
          ]
        : [
            // Для других платформ оставляем все пункты
            BottomNavigationBarItem(icon: Icon(Icons.print), label: "Печать"),
            BottomNavigationBarItem(
              icon: Icon(Icons.barcode_reader),
              label: "Сканировать",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fire_truck),
              label: "Перемещения",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: "Профиль",
            ),
          ];

    return BlocListener<UpdateCubit, UpdateState>(
      listener: (context, state) {
        if (state is UpdateAvailable && context.mounted) {
          showUpdateDialogIfNeeded(context, state.updateInfo);
        } else if (state is UpdateError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: invAppBar(
          // title: (() {
          //   // Определяем, какая строка должна быть на текущей странице
          //   if (_isWindows) {
          //     // Windows: 0=Печать, 1=Перемещения, 2=Профиль
          //     if (_currentIndex == 1) {
          //       return "История перемещений";
          //     } else {
          //       // На всех остальных — уведомления
          //       return null;
          //     }
          //   } else {
          //     // Не-Windows: 0=Печать, 1=Сканирование, 2=Перемещения, 3=Профиль
          //     if (_currentIndex == 2) {
          //       return "История перемещений";
          //     } else {
          //       // На всех остальных — уведомления
          //       return null;
          //     }
          //   }
          // })(),
          leading: IconButton(
            onPressed: () {
              context.router.push(CreateMovementRoute());
            },
            icon: Icon(Icons.add),
            tooltip: 'Создать перемещение',
          ),
          actions: (() {
            // Определяем, какая кнопка должна быть на текущей странице
            if (_isWindows) {
              // Windows: 0=Печать, 1=Перемещения, 2=Профиль
              if (_currentIndex == 0) {
                return [
                  IconButton(
                    onPressed: () {
                      context.router.push(PrinterSettingsRoute());
                    },
                    icon: Icon(Icons.settings),
                    tooltip: 'Настройки принтера',
                  ),
                ];
              } else if (_currentIndex == 1) {
                // Только на странице "Перемещения" — кнопка добавления
                return [
                  // IconButton(
                  //   onPressed: () {
                  //     context.router.push(CreateMovementRoute());
                  //   },
                  //   icon: Icon(Icons.add),
                  //   tooltip: 'Создать перемещение',
                  // ),
                  TextButton(
                    onPressed: () {
                      context.router.push(MovementRoute());
                    },
                    child: Text(
                      'Детально',
                      style: AppTextStyle.style16w600.copyWith(
                        color: AppColor.textPrimary,
                      ),
                    ),
                  ),
                ];
              } else {
                // На всех остальных — уведомления
                return [
                  IconButton(
                    onPressed: () {
                      context.router.push(NotificationRoute());
                    },
                    icon: Badge(
                      label: context.select(
                        (NotificationCubit cubit) => cubit.unread.isNotEmpty
                            ? Text(cubit.unread.length.toString())
                            : null,
                      ),
                      child: Icon(Icons.notifications),
                    ),
                    tooltip: 'Просмотреть уведомления',
                  ),
                ];
              }
            } else {
              // Не-Windows: 0=Печать, 1=Сканирование, 2=Перемещения, 3=Профиль
              if (_currentIndex == 0) {
                return [
                  IconButton(
                    onPressed: () {
                      context.router.push(PrinterSettingsRoute());
                    },
                    icon: Icon(Icons.settings),
                    tooltip: 'Настройки принтера',
                  ),
                ];
              } else if (_currentIndex == 2) {
                // Только на странице "Перемещения" — кнопка добавления
                return [
                  // IconButton(
                  //   onPressed: () {
                  //     context.router.push(CreateMovementRoute());
                  //   },
                  //   icon: Icon(Icons.add),
                  //   tooltip: 'Создать перемещение',
                  // ),
                  TextButton(
                    onPressed: () {
                      // Пустая функция как по требованию
                    },
                    child: Text(
                      'Детально',
                      style: AppTextStyle.style16w600.copyWith(
                        color: AppColor.textPrimary,
                      ),
                    ),
                  ),
                ];
              } else {
                // На всех остальных — уведомления
                return [
                  IconButton(
                    onPressed: () {
                      context.router.push(NotificationRoute());
                    },
                    icon: Badge(
                      label: context.select(
                        (NotificationCubit cubit) => cubit.unread.isNotEmpty
                            ? Text(cubit.unread.length.toString())
                            : null,
                      ),
                      child: Icon(Icons.notifications),
                    ),
                    tooltip: 'Просмотреть уведомления',
                  ),
                ];
              }
            }
          })(),
        ),
        body: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          onPageChanged: _onPageChanged,
          children: allPages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColor.textPrimary,
          unselectedItemColor: AppColor.textSecondary,
          unselectedLabelStyle: AppTextStyle.style14w400.copyWith(
            color: AppColor.textSecondary,
          ),
          selectedLabelStyle: AppTextStyle.style14w400.copyWith(
            color: AppColor.textPrimary,
          ),
          backgroundColor: AppColor.backgroundColor,
          items: bottomNavItems,
          onTap: _onItemTapped,
          currentIndex: _currentIndex,
        ),
      ),
    );
  }
}
