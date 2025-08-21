import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventerization_4aas/constants/theme/app_colors.dart';
import 'package:inventerization_4aas/constants/theme/app_text_styles.dart';

// Модели
import 'package:inventerization_4aas/models/user_model.dart';

// Bloc
import 'package:inventerization_4aas/cubit/user/user_cubit.dart';
import 'package:inventerization_4aas/router/route.dart';
import 'package:inventerization_4aas/screens/widgets/add_user_bottom_sheet.dart';
import 'package:inventerization_4aas/screens/widgets/delete_user_bottom_sheet.dart';
import 'package:inventerization_4aas/screens/widgets/edit_user_bottom_sheet.dart';
import 'package:inventerization_4aas/screens/widgets/main_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserState>(
      listener: (context, state) {
        if (state is UserLogoutSuccess) {
          // Перенаправляем на экран входа
          context.router.pushAndPopUntil(
            (LoginRoute()),
            predicate: (_) => false,
          );
        }
      },
      builder: (context, state) {
        final User? user = context.select((UserCubit cubit) => cubit.currentUser);
        
        // Проверка на null
        if (user == null) {
          return Scaffold(
            body: Center(
              child: Text('Загрузка...'),
            ),
          );
        }

        return Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // icon
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            width: 2,
                            color: AppColor.accentColor,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.person, size: 100),
                        ),
                      ),
                    ),
                    // name
                    SizedBox(height: 12),
                    Center(
                      child: Text(
                        '${user.firstName ?? ''} ${user.lastName ?? ''}',
                        style: AppTextStyle.style22w700,
                      ),
                    ),
                    // roles
                    Center(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: (user.roles ?? []).map((role) {
                          return Text(
                            role ?? '',
                            style: AppTextStyle.style16w400.copyWith(
                              color: AppColor.mainButton,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    // login
                    _buildProfileItem('Логин', user.login ?? 'Нет данных'),
                    // specials
                    Divider(),
                    (user.roles ?? []).contains("admin")
                        ? _buildAdminPanel(context)
                        : SizedBox.shrink(),

                    mainButton(
                      onPressed: () {
                        context.read<UserCubit>().logOut();
                      },
                      title: "Выйти",
                      color: AppColor.attentionColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyle.style16w400.copyWith(
                color: AppColor.textPrimary,
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyle.style16w600.copyWith(
              color: AppColor.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRolesSection(List<dynamic>? roles) {
    if (roles == null || roles.isEmpty) {
      return _buildProfileItem('Роли', 'Не назначены');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Роли',
            style: AppTextStyle.style16w400.copyWith(
              color: AppColor.textPrimary,
              overflow: TextOverflow.visible,
            ),
          ),
          Flexible(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: roles.map((role) {
                return Chip(
                  label: Text(role?.toString() ?? ''),
                  backgroundColor: AppColor.elementColor,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminPanel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Админ панель', style: AppTextStyle.style18w700),
        Text('Пользователи', style: AppTextStyle.style16w400),
        Wrap(
          children: [
            mainButton(
              onPressed: () {
                _showBottomSheet(context, AddUserBottomSheet());
              },
              title: 'Добавить пользователя',
            ),
            mainButton(
              onPressed: () {
                _showBottomSheet(context, EditUserBottomSheet());
              },
              title: 'Редактировать пользователя',
            ),
            mainButton(
              onPressed: () {
                _showBottomSheet(context, DeleteUserBottomSheet());
              },
              title: 'Удалить пользователя',
            ),
          ],
        ),
      ],
    );
  }

  void _showBottomSheet(BuildContext context, Widget whatToShow) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: whatToShow,
        );
      },
    );
  }
}