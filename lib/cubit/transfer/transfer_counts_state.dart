part of 'transfer_counts_cubit.dart';

@immutable
abstract class TransferCountsState {}

class TransferCountsInitial extends TransferCountsState {
  TransferCountsInitial();
}

class TransferCountsLoading extends TransferCountsState {
  TransferCountsLoading();
}

class TransferCountsLoaded extends TransferCountsState {
  final Map<int, Map<int, int>> countsByYearAndMonth;
  
  TransferCountsLoaded(this.countsByYearAndMonth);
}

class TransferCountsFailure extends TransferCountsState {
  final String message;
  
  TransferCountsFailure(this.message);
}