import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

// Модели
import 'package:inventerization_4aas/models/user_model.dart';
import 'package:inventerization_4aas/models/api_response_model.dart';

// Репозитории
import 'package:inventerization_4aas/repositories/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository userRepository;

  String username = '';
  String password = '';
  User? currentUser;

  static const String _keyUser = 'auth_user';
  static const String _keyPassword =
      'auth_password'; // ⚠️ Небезопасно! См. ниже

  UserCubit({required this.userRepository}) : super(UserAuthInitial()){
    checkAutoLogin(); // Проверяем при создании
  }

    Future<void> checkAutoLogin() async {
    emit(UserAuthLoading());

    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_keyUser);
    final savedPassword = prefs.getString(_keyPassword);

    if (userJson != null && savedPassword != null) {
      try {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        currentUser = User.fromJson(userMap);
        username = currentUser!.login!;
        password = savedPassword; // Только если ты хочешь сохранять пароль

        emit(UserAuthSuccess(currentUser!, message: 'Автоматический вход'));
        return;
      } catch (e) {
        // Если JSON сломан — очищаем
        await prefs.remove(_keyUser);
        await prefs.remove(_keyPassword);
      }
    }

    emit(UserAuthInitial());
  }

  Future<void> signIn() async {
    if (username.isEmpty || password.isEmpty) {
      emit(UserAuthFailure('Введите email и пароль'));
      return;
    }

    emit(UserAuthLoading());

    try {
      final ApiResponse response = await userRepository.loginUser(
        username.trim().toLowerCase(),
        password.trim(),
      );

      if (response.success) {
        currentUser = User.fromJson(response.data as Map<String, dynamic>);

        // Сохраняем в SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyUser, json.encode(currentUser!.toJson()));
        await prefs.setString(_keyPassword, password); // ⚠️ Осторожно! См. ниже

        emit(UserAuthSuccess(currentUser!, message: response.message ?? ''));
      } else {
        emit(UserAuthFailure(response.message ?? 'Ошибка входа'));
      }
    } catch (e) {
      emit(UserAuthFailure('Произошла ошибка: $e'));
    }
  }

  Future<void> createUser(
    String login,
    String password,
    String firstName,
    String lastName,
    String patronymic,
    String roles,
  ) async {
    // Валидация идет на уровне UI
    emit(UserRegisterLoading());

    try {
      final ApiResponse response = await userRepository.createUser(
        login.trim().toLowerCase(),
        password.trim(),
        firstName,
        lastName,
        patronymic,
        roles.trim().toLowerCase(),
      );

      if (response.success) {
        emit(UserRegisterSuccess(message: response.message ?? ''));
      } else {
        emit(
          UserRegisterFailure(
            response.message ?? 'Ошибка создания пользователя',
          ),
        );
      }
    } catch (e) {
      emit(UserRegisterFailure('Произошла ошибка: $e '));
    }
  }

  Future<void> deleteUser(String id) async {
    // Валидация идет на уровне UI
    emit(UserRegisterLoading());

    try {
      final ApiResponse response = await userRepository.deleteUser(id);

      if (response.success) {
        emit(UserRegisterSuccess(message: response.message ?? ''));
      } else {
        emit(
          UserRegisterFailure(
            response.message ?? 'Ошибка удаления пользователя',
          ),
        );
      }
    } catch (e) {
      emit(UserRegisterFailure('Произошла ошибка: $e '));
    }
  }

  Future<void> updateUser(
    String userId,
    String login,
    String? password,
    String firstName,
    String lastName,
    String patronymic,
    String roles,
  ) async {
    emit(UserRegisterLoading());

    try {
      final ApiResponse response = await userRepository.updateUser(
        userId,
        login.trim().toLowerCase(),
        password?.trim(),
        firstName,
        lastName,
        patronymic,
        roles.toLowerCase(),
      );

      if (response.success) {
        emit(UserRegisterSuccess(message: response.message ?? ''));
      } else {
        emit(
          UserRegisterFailure(response.message ?? 'Ошибка обновления данных'),
        );
      }
    } catch (e) {
      emit(UserRegisterFailure('Произошла ошибка: $e'));
    }
  }

  Future<void> logOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
    await prefs.remove(_keyPassword);

    username = '';
    password = '';
    currentUser = null;

    emit(UserLogoutSuccess());
  }

  Future<List<User>> getUsers() async {
    List<User> allUsers = [];

    try {
      allUsers = await userRepository.getUsers();
    } catch (e) {
      emit(UserRegisterFailure('Произошла ошибка: $e'));
    }

    return allUsers;
  }

  // Методы для обновления полей формы
  void setUsername(String value) {
    username = value;
    emit(state); // Опционально: обновляем состояние для валидации/отображения
  }

  void setPassword(String value) {
    password = value;
    emit(state); // Опционально
  }
}
