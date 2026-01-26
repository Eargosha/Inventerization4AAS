part of 'update_cubit.dart';

@immutable
abstract class UpdateState {}

class UpdateInitial extends UpdateState {}

class UpdateChecking extends UpdateState {}

class UpdateAvailable extends UpdateState {
  final UpdateInfo updateInfo;
  UpdateAvailable(this.updateInfo);
}

class UpdateNotNeeded extends UpdateState {}

class UpdateError extends UpdateState {
  final String message;
  UpdateError(this.message);
}