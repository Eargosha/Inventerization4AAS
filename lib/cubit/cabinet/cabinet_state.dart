part of 'cabinet_cubit.dart';

@immutable
abstract class CabinetState {}

class CabinetInitial extends CabinetState {}

class CabinetLoading extends CabinetState {}

class CabinetLoadSuccess extends CabinetState {
  final List<Cabinet> cabinets;
  final String message;

  CabinetLoadSuccess({
    required this.cabinets,
    this.message = 'Данные успешно загружены',
  });
}

class CabinetFailure extends CabinetState {
  final String message;

  CabinetFailure(this.message);
}