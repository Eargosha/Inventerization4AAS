import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventerization_4aas/cubit/notification/notification_cubit.dart';
import 'package:inventerization_4aas/router/route.dart';
import 'package:inventerization_4aas/screens/home_screen_pages/movement_page.dart';
import 'package:inventerization_4aas/screens/home_screen_pages/profile_page.dart';
import 'package:inventerization_4aas/screens/home_screen_pages/scan_page.dart';
import 'package:inventerization_4aas/screens/widgets/app_bar.dart';
import 'package:inventerization_4aas/constants/theme/app_colors.dart';
import 'package:inventerization_4aas/constants/theme/app_text_styles.dart';

@RoutePage()
class MainScreen extends StatefulWidget {
  MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
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
            MovementScreen(),
            ProfileScreen(),
          ]
        : [
            // Для других платформ оставляем все страницы
            ScanScreen(),
            MovementScreen(),
            ProfileScreen(),
          ];

    List<BottomNavigationBarItem> bottomNavItems = _isWindows
        ? [
            // Для Windows убираем пункт сканирования
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

    return Scaffold(
      appBar: invAppBar(
        actions: _isWindows
            ? _currentIndex == 0
                  ? [
                      IconButton(
                        onPressed: () {
                          context.router.push(CreateMovementRoute());
                        },
                        icon: Icon(Icons.add),
                        tooltip: 'Создать перемещение',
                      ),
                    ]
                  : [
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
                    ]
            : _currentIndex != 1
            ? [
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
              ]
            : [
                IconButton(
                  onPressed: () {
                    context.router.push(CreateMovementRoute());
                  },
                  icon: Icon(Icons.add),
                  tooltip: 'Создать перемещение',
                ),
              ],
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
    );
  }
}
