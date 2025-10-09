part of 'transfer_cubit.dart';

@immutable
abstract class TransferState {}

class TransferInitial implements TransferState {
  const TransferInitial();
}

class TransferLoading implements TransferState {
  const TransferLoading();
}

class TransferCreateSuccess implements TransferState {
  final String message;
  final Transfer transfer;

  TransferCreateSuccess(this.transfer, {this.message = 'Перенос успешно создан'});
}

class TransferUpdateSuccess implements TransferState {
  final String message;
  final Transfer transfer;

  TransferUpdateSuccess(this.transfer, {this.message = 'Перенос успешно обновлен'});
}

class TransferDeleteSuccess implements TransferState {
  final String message;
  final int id;

  TransferDeleteSuccess({required this.id, this.message = 'Перенос успешно удален'});
}

class TransferFailure implements TransferState {
  final String message;

  TransferFailure(this.message);
}

class TransferLoadSuccess extends TransferState {
  final String message;
  final List<Transfer> transfers;

  TransferLoadSuccess({required this.message, required this.transfers});
}

class TransferExcelExported extends TransferState {
  final List<int> fileBytes;

  TransferExcelExported(this.fileBytes);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransferExcelExported &&
          runtimeType == other.runtimeType &&
          _listEquals(fileBytes, other.fileBytes);

  @override
  int get hashCode => fileBytes.hashCode;

  // Вспомогательный метод для сравнения списков
  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class TransferLastFound extends TransferState {
  final Transfer transfer;

  TransferLastFound(this.transfer);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransferLastFound &&
          runtimeType == other.runtimeType &&
          transfer == other.transfer;

  @override
  int get hashCode => transfer.hashCode;
}