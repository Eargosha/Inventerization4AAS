import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventerization_4aas/cubit/notification/notification_cubit.dart';
import 'package:inventerization_4aas/cubit/user/user_cubit.dart';
import 'package:inventerization_4aas/screens/widgets/checkbox.dart';
import 'package:inventerization_4aas/screens/widgets/input_field_widget.dart';
import 'package:inventerization_4aas/screens/widgets/main_button.dart';
import 'package:inventerization_4aas/constants/theme/app_colors.dart';
import 'package:inventerization_4aas/constants/theme/app_text_styles.dart';

class AddUserBottomSheet extends StatefulWidget {
  const AddUserBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddUserBottomSheet> createState() => _AddUserBottomSheetState();
}

class _AddUserBottomSheetState extends State<AddUserBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  late String _login;
  late String _password;
  late String _firstName;
  late String _lastName;
  String _patronymic = '';

  bool isAdmin = false;
  bool isEmployee = false;

  void _submitForm(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      // Формируем список ролей
      List<String> roles = ["user"];
      if (isAdmin) roles.add("admin");
      if (isEmployee) roles.add("fho");
      print(roles.join(','));

      // Вызываем Cubit
      context.read<UserCubit>().createUser(
        _login,
        _password,
        _firstName,
        _lastName,
        _patronymic,
        roles.join(','),
      );

      context.read<NotificationCubit>().sendNotification(
                            title: 'Зарегистрирован новый пользователь',
                            body:
                                'Был зарегистрирован новый пользователь с логином: $_login, именем: $_firstName $_lastName $_patronymic, ролями: ${roles.join(',')} ',
                            destinationRoles: ['admin'],
                          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BlocConsumer<UserCubit, UserState>(
        listener: (context, state) {
          if (state is UserRegisterSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.of(context).pop(); // Закрываем BottomSheet
          }

          if (state is UserRegisterFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Регистрация пользователя',
                      style: AppTextStyle.style18w700.copyWith(
                        color: AppColor.textPrimary,
                      ),
                    ),
                    SizedBox(height: 16),

                    InputField(
                      placeholder: 'Логин',
                      obscureText: false,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Введите логин' : null,
                      onChanged: (value) => _login = value!,
                    ),

                    SizedBox(height: 8),
                    InputField(
                      placeholder: 'Пароль',
                      obscureText: true,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Введите пароль' : null,
                      onChanged: (value) => _password = value!,
                    ),

                    SizedBox(height: 8),
                    InputField(
                      placeholder: 'Имя',
                      obscureText: false,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Введите имя' : null,
                      onChanged: (value) => _firstName = value!,
                    ),

                    SizedBox(height: 8),
                    InputField(
                      placeholder: 'Фамилия',
                      obscureText: false,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Введите фамилию' : null,
                      onChanged: (value) => _lastName = value!,
                    ),

                    SizedBox(height: 8),
                    InputField(
                      placeholder: 'Отчество (необязательно)',
                      obscureText: false,
                      onChanged: (value) => _patronymic = value ?? '',
                    ),

                    SizedBox(height: 16),

                    invCheckbox(
                      value: isEmployee,
                      onChanged: (value) {
                        setState(() {
                          isEmployee = value;
                        });
                      },
                      text: 'Сотрудник ФХО',
                    ),
                    invCheckbox(
                      value: isAdmin,
                      onChanged: (value) {
                        /////////Добавление ролей не работает
                        setState(() {
                          isAdmin = value;
                        });
                      },
                      text: 'Администратор',
                    ),

                    SizedBox(height: 16),

                    if (state is UserRegisterLoading)
                      Center(child: CircularProgressIndicator())
                    else
                      mainButton(
                        onPressed: () => _submitForm(context),
                        title: 'Зарегистрировать',
                      ),

                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
