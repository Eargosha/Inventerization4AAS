import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventerization_4aas/cubit/user/user_cubit.dart';
import 'package:inventerization_4aas/models/user_model.dart';
import 'package:inventerization_4aas/screens/widgets/checkbox.dart';
import 'package:inventerization_4aas/screens/widgets/input_field_widget.dart';
import 'package:inventerization_4aas/screens/widgets/main_button.dart';
import 'package:inventerization_4aas/constants/theme/app_colors.dart';
import 'package:inventerization_4aas/constants/theme/app_text_styles.dart';

class EditUserBottomSheet extends StatefulWidget {
  const EditUserBottomSheet({Key? key}) : super(key: key);

  @override
  State<EditUserBottomSheet> createState() => _EditUserBottomSheetState();
}

class _EditUserBottomSheetState extends State<EditUserBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  late String _login;
  late String _password;
  late String _firstName;
  late String _lastName;
  late String _patronymic;
  bool isAdmin = false;
  bool isEmployee = false;

  List<User> allUsers = [];
  User? selectedUser;

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await context.read<UserCubit>().getUsers();
    setState(() {
      allUsers = users;
    });
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      // Собираем роли
      List<String> roles = ['user'];
      if (isAdmin) roles.add('admin');
      if (isEmployee) roles.add('fho');

      // Обновляем пользователя
      context.read<UserCubit>().updateUser(
        selectedUser!.id.toString(),
        _login,
        _password.isNotEmpty ? _password : null,
        _firstName,
        _lastName,
        _patronymic,
        roles.join(','),
      );

      Navigator.of(context).pop(); // закрываем BottomSheet
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserState>(
      listener: (context, state) {
        if (state is UserRegisterSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
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
            child: selectedUser == null
                ? _buildUserSelector()
                : _buildEditForm(context),
          ),
        );
      },
    );
  }

  Widget _buildUserSelector() {
    // Фильтруем список пользователей по поисковому запросу
    final filteredUsers = _searchQuery.isEmpty
        ? allUsers
        : allUsers.where((user) {
            final fullName =
                '${user.firstName} ${user.lastName} ${user.patronymic}'
                    .toLowerCase();
            return fullName.contains(_searchQuery.toLowerCase());
          }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.arrow_back),
              ),
              SizedBox(width: 16,),
              Text(
                'Выберите пользователя',
                style: AppTextStyle.style18w700.copyWith(
                  color: AppColor.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 16),
          child: InputField(
            placeholder: 'Поиск',
            obscureText: false,
            onChanged: (text) {
              setState(() {
                _searchQuery = text!;
              });
            },
            search: true,
          ),
        ),
        SizedBox(height: 12),
        Divider(),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  if (filteredUsers.isEmpty)
                    Center(child: Text('Пользователи не найдены'))
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: filteredUsers.length,
                      separatorBuilder: (_, __) => Divider(),
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        return ListTile(
                          title: Text('${user.firstName} ${user.lastName}'),
                          subtitle: Text(user.login ?? ''),
                          onTap: () {
                            setState(() {
                              selectedUser = user;
                              _initFieldsFromUser(user);
                            });
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _initFieldsFromUser(User user) {
    _searchQuery = ''; // сброс поиска
    _login = user.login ?? '';
    _password = '';
    _firstName = user.firstName ?? '';
    _lastName = user.lastName ?? '';
    _patronymic = user.patronymic ?? '';
    isAdmin = user.roles?.contains('admin') ?? false;
    isEmployee = user.roles?.contains('fho') ?? false;
  }

  Widget _buildEditForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    selectedUser = null;
                  });
                },
                icon: Icon(Icons.arrow_back),
              ),
              Text(
                'Редактирование пользователя',
                style: AppTextStyle.style18w700.copyWith(
                  color: AppColor.textPrimary,
                ),
              ),
              SizedBox(width: 24),
            ],
          ),

          SizedBox(height: 16),

          InputField(
            initialValue: _login,
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
            onChanged: (value) => _password = value ?? '',
          ),

          SizedBox(height: 8),
          InputField(
            placeholder: 'Имя',
            obscureText: false,
            initialValue: _firstName,
            validator: (value) => value?.isEmpty ?? true ? 'Введите имя' : null,
            onChanged: (value) => _firstName = value!,
          ),

          SizedBox(height: 8),
          InputField(
            placeholder: 'Фамилия',
            obscureText: false,
            initialValue: _lastName,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Введите фамилию' : null,
            onChanged: (value) => _lastName = value!,
          ),

          SizedBox(height: 8),
          InputField(
            initialValue: _patronymic,
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
              setState(() {
                isAdmin = value;
              });
            },
            text: 'Администратор',
          ),

          SizedBox(height: 16),

          mainButton(
            onPressed: () => _submitForm(context),
            title: 'Сохранить изменения',
          ),

          SizedBox(height: 16),
        ],
      ),
    );
  }
}
