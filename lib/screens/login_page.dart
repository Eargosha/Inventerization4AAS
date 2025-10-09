import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventerization_4aas/cubit/notification/notification_cubit.dart';
import 'package:inventerization_4aas/cubit/user/user_cubit.dart';
import 'package:inventerization_4aas/router/route.dart';
import 'package:inventerization_4aas/screens/widgets/app_bar.dart';
import 'package:inventerization_4aas/screens/widgets/input_field_widget.dart';
import 'package:inventerization_4aas/screens/widgets/main_button.dart';
import 'package:inventerization_4aas/constants/theme/app_colors.dart';
import 'package:inventerization_4aas/constants/theme/app_text_styles.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // 🔑 ВАЖНО: не изменять размер при клавиатуре
      appBar: invAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // Основной контент (форма)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BlocConsumer<UserCubit, UserState>(
                  listener: (context, state) {
                    if (state is UserAuthSuccess) {
                      context.read<NotificationCubit>().startPolling(state.user.roles!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Успешная авторизация')),
                      );
                      context.router.replace(MainRoute());
                    }

                    if (state is UserAuthFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    }
                  },
                  builder: (context, state) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // === Picture ===
                          Image.asset(
                            'assets/login-screen-picture.png',
                            width: 100,
                            height: 100,
                          ),
                          const SizedBox(height: 24),

                          // === Title ===
                          Text(
                            'Войдите, чтобы продолжить',
                            style: AppTextStyle.style22w400.copyWith(
                              color: AppColor.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // === Email ===
                          InputField(
                            placeholder: 'Имя пользователя (почта)',
                            obscureText: false,
                            onChanged: (value) {
                              context.read<UserCubit>().setUsername(value!);
                            },
                          ),
                          const SizedBox(height: 8),

                          // === Password ===
                          InputField(
                            placeholder: 'Пароль',
                            obscureText: true,
                            onChanged: (value) {
                              context.read<UserCubit>().setPassword(value!);
                            },
                          ),
                          const SizedBox(height: 24),

                          // === Loader или Button ===
                          if (state is UserAuthLoading)
                            Center(child: CircularProgressIndicator())
                          else
                            mainButton(
                              onPressed: () => context.read<UserCubit>().signIn(),
                              title: 'Войти',
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // === Нижняя статичная часть ===
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text('Версия: 0.8.7', style: AppTextStyle.style14w400),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Контакт: 04ap.eivanov@arbitr.ru',
                style: AppTextStyle.style14w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}