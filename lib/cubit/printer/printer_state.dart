part of 'printer_cubit.dart';

@immutable
abstract class PrinterStatusState {}

// Начальное состояние
class PrinterStatusInitial extends PrinterStatusState {}

// ================== Состояния для получения СЕТЕВОГО СТАТУСА (ONLINE/OFFLINE) ==================

class PrinterNetworkStatusLoading extends PrinterStatusState {}

class PrinterNetworkStatusLoadSuccess extends PrinterStatusState {
  final bool isOnline;
  final String message;

  PrinterNetworkStatusLoadSuccess({required this.isOnline, this.message = 'Статус успешно получен'});
}

class PrinterNetworkStatusFailure extends PrinterStatusState {
  final String message;

  PrinterNetworkStatusFailure(this.message);
}

// ================== Состояния для ПЕЧАТИ ЭТИКЕТКИ ==================

class PrinterLabelPrinting extends PrinterStatusState {}

class PrinterLabelPrintSuccess extends PrinterStatusState {
  final String message;

  PrinterLabelPrintSuccess({required this.message});
}

class PrinterLabelPrintAttention extends PrinterStatusState {
  final String message;

  PrinterLabelPrintAttention({required this.message});
}

class PrinterLabelPrintFailure extends PrinterStatusState {
  final String message;

  PrinterLabelPrintFailure(this.message);
}

// ================== Состояния для КОНФИГУРАЦИИ ПРИНТЕРА ==================

class PrinterConfiguring extends PrinterStatusState {}

class PrinterConfigurationSuccess extends PrinterStatusState {
  final String message;

  PrinterConfigurationSuccess({required this.message});
}

class PrinterConfigurationFailure extends PrinterStatusState {
  final String message;

  PrinterConfigurationFailure(this.message);
}