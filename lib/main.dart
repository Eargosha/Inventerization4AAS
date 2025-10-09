// main.dart

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventerization_4aas/cubit/cabinet/cabinet_cubit.dart';
import 'package:inventerization_4aas/cubit/notification/notification_cubit.dart';
import 'package:inventerization_4aas/cubit/printer/printer_cubit.dart';
import 'package:inventerization_4aas/cubit/product/product_cubit.dart';
import 'package:inventerization_4aas/cubit/transfer/transfer_counts_cubit.dart';
import 'package:inventerization_4aas/cubit/transfer/transfer_cubit.dart';
import 'package:inventerization_4aas/cubit/user/user_cubit.dart';
import 'package:inventerization_4aas/permission_manafer.dart';
import 'package:inventerization_4aas/repositories/cabinet_repository.dart';
import 'package:inventerization_4aas/repositories/network_repository.dart';
import 'package:inventerization_4aas/repositories/notification_repository.dart';
import 'package:inventerization_4aas/repositories/notification_service.dart';
import 'package:inventerization_4aas/repositories/printer_status_repository.dart';
import 'package:inventerization_4aas/repositories/product_repository.dart';
import 'package:inventerization_4aas/repositories/transfer_repository.dart';
import 'package:inventerization_4aas/repositories/user_repository.dart';
import 'package:inventerization_4aas/router/route.dart';
import 'package:inventerization_4aas/constants/theme/app_colors.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Настройка window_manager только для desktop платформ
  if (!kIsWeb && (Platform.isWindows)) {
    await windowManager.ensureInitialized();

    // Установка размера окна
    WindowOptions windowOptions = const WindowOptions(
      size: Size(540, 800),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'Инвентаризация 4ААС',
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setResizable(false); // Запрет изменения размера
      await windowManager.show();
      await windowManager.focus();
    });
  }

  final permissionManager = PermissionManager();
  final permissionsGranted = await permissionManager.requestAppPermissions();

  final networkChecker = NetworkChecker();
  final isNetworkOk = await networkChecker.isNetworkValid();

  if (!isNetworkOk) {
    runApp(const NetworkRequiredApp());
    return;
  }

  await NotificationService().init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              UserCubit(userRepository: UserRepository())..checkAutoLogin(),
        ),
        BlocProvider(
          create: (context) => TransferCubit(
            transferRepository: TransferRepository()..loadTransfers({}),
          ),
        ),
        BlocProvider(
          create: (context) =>
              TransferCountsCubit(transferRepository: TransferRepository()),
        ),
        BlocProvider(
          create: (context) =>
              ProductCubit(productRepository: ProductRepository())
                ..loadProducts(),
        ),
        BlocProvider(
          create: (context) =>
              CabinetCubit(cabinetRepository: CabinetRepository())
                ..loadCabinets(),
        ),
        BlocProvider(
          create: (context) =>
              NotificationCubit(repository: NotificationRepository()),
        ),
        BlocProvider(
          create: (context) => PrinterStatusCubit(
            printerStatusRepository: PrinterStatusRepository(),
          ),
        ),
      ],
      child: MainApp(),
    ),
  );
}

final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class NetworkRequiredApp extends StatelessWidget {
  const NetworkRequiredApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: AppBarTheme(backgroundColor: Colors.grey[100]),
      ),
      scaffoldMessengerKey: _scaffoldMessengerKey, // ✅ КЛЮЧЕВАЯ СТРОКА
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.network_check, size: 80, color: Colors.orange),
              SizedBox(height: 20),
              Text(
                'Нет подключения к корпоративной сети',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Устройство должно быть в подсети\n10.104.x.x\nи иметь доступ к серверу',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  final ok = await NetworkChecker().isNetworkValid();
                  if (ok) {
                    await NotificationService().init();
                    runApp(
                      MultiBlocProvider(
                        providers: [
                          BlocProvider(
                            create: (context) =>
                                UserCubit(userRepository: UserRepository())
                                  ..checkAutoLogin(),
                          ),
                          BlocProvider(
                            create: (context) => TransferCubit(
                              transferRepository: TransferRepository()
                                ..loadTransfers({}),
                            ),
                          ),
                          BlocProvider(
                            create: (context) => ProductCubit(
                              productRepository: ProductRepository(),
                            )..loadProducts(),
                          ),
                          BlocProvider(
                            create: (context) => CabinetCubit(
                              cabinetRepository: CabinetRepository(),
                            )..loadCabinets(),
                          ),
                          BlocProvider(
                            create: (context) => NotificationCubit(
                              repository: NotificationRepository(),
                            ),
                          ),
                        ],
                        child: MainApp(),
                      ),
                    );
                  } else {
                    _scaffoldMessengerKey.currentState?.showSnackBar(
                      SnackBar(content: Text('Подключение не установлено')),
                    );
                  }
                },
                icon: Icon(Icons.refresh),
                label: Text('Проверить снова'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  final _appRouter = AppRouter();

  final ThemeData _themeData = ThemeData(
    scaffoldBackgroundColor: AppColor.backgroundColor,
    appBarTheme: const AppBarTheme(backgroundColor: AppColor.backgroundColor),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _appRouter.config(),
      theme: _themeData,
    );
  }
}
