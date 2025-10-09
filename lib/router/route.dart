import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:inventerization_4aas/models/cabinet_model.dart';
import 'package:inventerization_4aas/models/product_model.dart';
import 'package:inventerization_4aas/models/transfer_model.dart';
import 'package:inventerization_4aas/screens/create_movement_page.dart';
import 'package:inventerization_4aas/screens/home_screen_pages/month_detail_page.dart';
import 'package:inventerization_4aas/screens/home_screen_pages/printer_settings_page.dart';
import 'package:inventerization_4aas/screens/login_page.dart';
import 'package:inventerization_4aas/screens/main_page.dart';
import 'package:inventerization_4aas/screens/movement_object_page.dart';
import 'package:inventerization_4aas/screens/notification_page.dart';
import 'package:inventerization_4aas/screens/object_page.dart';
import 'package:inventerization_4aas/screens/widgets/barcode_scaner_overlay_screen.dart';

part 'route.gr.dart';

// flutter pub run build_runner build
@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: LoginRoute.page, initial: true), // initial - начинаем с нее
    AutoRoute(page: MainRoute.page),
    AutoRoute(page: MonthDetailRoute.page),
    AutoRoute(page: NotificationRoute.page),
    AutoRoute(page: CreateMovementRoute.page),
    AutoRoute(page: MovementObjectRoute.page),
    AutoRoute(page: ObjectRoute.page),
    AutoRoute(page: BarcodeScannerOverlayRoute.page),
    AutoRoute(page: PrinterSettingsRoute.page),
  ];
}
