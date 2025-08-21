part of 'user_cubit.dart';

@immutable
abstract class UserState {}

class UserAuthInitial extends UserState {}

class UserAuthLoading extends UserState {}

class UserAuthSuccess extends UserState {
  final User user;
  final String message;

  UserAuthSuccess(this.user, {this.message = 'Успешный вход'});
}

class UserAuthFailure extends UserState {
  final String message;
  UserAuthFailure(this.message);
}

class UserRegisterLoading extends UserState {}

class UserRegisterSuccess extends UserState {
  final String message;

  UserRegisterSuccess({this.message = 'Пользователь создан'});
}

class UserRegisterFailure extends UserState {
  final String message;
  UserRegisterFailure(this.message);
}

class UserLogoutSuccess extends UserState {}
