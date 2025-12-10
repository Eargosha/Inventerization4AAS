// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'route.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    BarcodeScannerOverlayRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const BarcodeScannerOverlayScreen(),
      );
    },
    CreateMovementRoute.name: (routeData) {
      final args = routeData.argsAs<CreateMovementRouteArgs>(
          orElse: () => const CreateMovementRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CreateMovementScreen(
          key: args.key,
          selectedProduct: args.selectedProduct,
          selectedFromWhere: args.selectedFromWhere,
          isEditing: args.isEditing,
          transferToEdit: args.transferToEdit,
        ),
      );
    },
    LoginRoute.name: (routeData) {
      final args = routeData.argsAs<LoginRouteArgs>(
          orElse: () => const LoginRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: LoginScreen(key: args.key),
      );
    },
    MainRoute.name: (routeData) {
      final args =
          routeData.argsAs<MainRouteArgs>(orElse: () => const MainRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: MainScreen(key: args.key),
      );
    },
    MonthDetailRoute.name: (routeData) {
      final args = routeData.argsAs<MonthDetailRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: MonthDetailScreen(
          key: args.key,
          month: args.month,
          year: args.year,
        ),
      );
    },
    MovementObjectRoute.name: (routeData) {
      final args = routeData.argsAs<MovementObjectRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: MovementObjectScreen(
          key: args.key,
          transfer: args.transfer,
        ),
      );
    },
    MovementRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: MovementScreen(),
      );
    },
    MovementsHistoryRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const MovementsHistoryScreen(),
      );
    },
    NotificationRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const NotificationScreen(),
      );
    },
    ObjectRoute.name: (routeData) {
      final args = routeData.argsAs<ObjectRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ObjectScreen(
          key: args.key,
          product: args.product,
        ),
      );
    },
    PrinterSettingsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const PrinterSettingsScreen(),
      );
    },
  };
}

/// generated route for
/// [BarcodeScannerOverlayScreen]
class BarcodeScannerOverlayRoute extends PageRouteInfo<void> {
  const BarcodeScannerOverlayRoute({List<PageRouteInfo>? children})
      : super(
          BarcodeScannerOverlayRoute.name,
          initialChildren: children,
        );

  static const String name = 'BarcodeScannerOverlayRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [CreateMovementScreen]
class CreateMovementRoute extends PageRouteInfo<CreateMovementRouteArgs> {
  CreateMovementRoute({
    Key? key,
    Product? selectedProduct,
    Cabinet? selectedFromWhere,
    bool isEditing = false,
    Transfer? transferToEdit,
    List<PageRouteInfo>? children,
  }) : super(
          CreateMovementRoute.name,
          args: CreateMovementRouteArgs(
            key: key,
            selectedProduct: selectedProduct,
            selectedFromWhere: selectedFromWhere,
            isEditing: isEditing,
            transferToEdit: transferToEdit,
          ),
          initialChildren: children,
        );

  static const String name = 'CreateMovementRoute';

  static const PageInfo<CreateMovementRouteArgs> page =
      PageInfo<CreateMovementRouteArgs>(name);
}

class CreateMovementRouteArgs {
  const CreateMovementRouteArgs({
    this.key,
    this.selectedProduct,
    this.selectedFromWhere,
    this.isEditing = false,
    this.transferToEdit,
  });

  final Key? key;

  final Product? selectedProduct;

  final Cabinet? selectedFromWhere;

  final bool isEditing;

  final Transfer? transferToEdit;

  @override
  String toString() {
    return 'CreateMovementRouteArgs{key: $key, selectedProduct: $selectedProduct, selectedFromWhere: $selectedFromWhere, isEditing: $isEditing, transferToEdit: $transferToEdit}';
  }
}

/// generated route for
/// [LoginScreen]
class LoginRoute extends PageRouteInfo<LoginRouteArgs> {
  LoginRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          LoginRoute.name,
          args: LoginRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static const PageInfo<LoginRouteArgs> page = PageInfo<LoginRouteArgs>(name);
}

class LoginRouteArgs {
  const LoginRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'LoginRouteArgs{key: $key}';
  }
}

/// generated route for
/// [MainScreen]
class MainRoute extends PageRouteInfo<MainRouteArgs> {
  MainRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          MainRoute.name,
          args: MainRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'MainRoute';

  static const PageInfo<MainRouteArgs> page = PageInfo<MainRouteArgs>(name);
}

class MainRouteArgs {
  const MainRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'MainRouteArgs{key: $key}';
  }
}

/// generated route for
/// [MonthDetailScreen]
class MonthDetailRoute extends PageRouteInfo<MonthDetailRouteArgs> {
  MonthDetailRoute({
    Key? key,
    required String month,
    required String year,
    List<PageRouteInfo>? children,
  }) : super(
          MonthDetailRoute.name,
          args: MonthDetailRouteArgs(
            key: key,
            month: month,
            year: year,
          ),
          initialChildren: children,
        );

  static const String name = 'MonthDetailRoute';

  static const PageInfo<MonthDetailRouteArgs> page =
      PageInfo<MonthDetailRouteArgs>(name);
}

class MonthDetailRouteArgs {
  const MonthDetailRouteArgs({
    this.key,
    required this.month,
    required this.year,
  });

  final Key? key;

  final String month;

  final String year;

  @override
  String toString() {
    return 'MonthDetailRouteArgs{key: $key, month: $month, year: $year}';
  }
}

/// generated route for
/// [MovementObjectScreen]
class MovementObjectRoute extends PageRouteInfo<MovementObjectRouteArgs> {
  MovementObjectRoute({
    Key? key,
    required Transfer transfer,
    List<PageRouteInfo>? children,
  }) : super(
          MovementObjectRoute.name,
          args: MovementObjectRouteArgs(
            key: key,
            transfer: transfer,
          ),
          initialChildren: children,
        );

  static const String name = 'MovementObjectRoute';

  static const PageInfo<MovementObjectRouteArgs> page =
      PageInfo<MovementObjectRouteArgs>(name);
}

class MovementObjectRouteArgs {
  const MovementObjectRouteArgs({
    this.key,
    required this.transfer,
  });

  final Key? key;

  final Transfer transfer;

  @override
  String toString() {
    return 'MovementObjectRouteArgs{key: $key, transfer: $transfer}';
  }
}

/// generated route for
/// [MovementScreen]
class MovementRoute extends PageRouteInfo<void> {
  const MovementRoute({List<PageRouteInfo>? children})
      : super(
          MovementRoute.name,
          initialChildren: children,
        );

  static const String name = 'MovementRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [MovementsHistoryScreen]
class MovementsHistoryRoute extends PageRouteInfo<void> {
  const MovementsHistoryRoute({List<PageRouteInfo>? children})
      : super(
          MovementsHistoryRoute.name,
          initialChildren: children,
        );

  static const String name = 'MovementsHistoryRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [NotificationScreen]
class NotificationRoute extends PageRouteInfo<void> {
  const NotificationRoute({List<PageRouteInfo>? children})
      : super(
          NotificationRoute.name,
          initialChildren: children,
        );

  static const String name = 'NotificationRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ObjectScreen]
class ObjectRoute extends PageRouteInfo<ObjectRouteArgs> {
  ObjectRoute({
    Key? key,
    required Product product,
    List<PageRouteInfo>? children,
  }) : super(
          ObjectRoute.name,
          args: ObjectRouteArgs(
            key: key,
            product: product,
          ),
          initialChildren: children,
        );

  static const String name = 'ObjectRoute';

  static const PageInfo<ObjectRouteArgs> page = PageInfo<ObjectRouteArgs>(name);
}

class ObjectRouteArgs {
  const ObjectRouteArgs({
    this.key,
    required this.product,
  });

  final Key? key;

  final Product product;

  @override
  String toString() {
    return 'ObjectRouteArgs{key: $key, product: $product}';
  }
}

/// generated route for
/// [PrinterSettingsScreen]
class PrinterSettingsRoute extends PageRouteInfo<void> {
  const PrinterSettingsRoute({List<PageRouteInfo>? children})
      : super(
          PrinterSettingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'PrinterSettingsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}
