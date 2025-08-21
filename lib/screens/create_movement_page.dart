import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventerization_4aas/cubit/notification/notification_cubit.dart';
import 'package:inventerization_4aas/cubit/product/product_cubit.dart';
import 'package:inventerization_4aas/cubit/cabinet/cabinet_cubit.dart';
import 'package:inventerization_4aas/cubit/transfer/transfer_cubit.dart';
import 'package:inventerization_4aas/cubit/user/user_cubit.dart';
import 'package:inventerization_4aas/models/product_model.dart';
import 'package:inventerization_4aas/models/cabinet_model.dart';
import 'package:inventerization_4aas/models/transfer_model.dart';
import 'package:inventerization_4aas/router/route.dart';
import 'package:inventerization_4aas/screens/widgets/app_bar.dart';
import 'package:inventerization_4aas/screens/widgets/input_field_widget.dart';
import 'package:inventerization_4aas/screens/widgets/main_button.dart';
import 'package:inventerization_4aas/constants/theme/app_colors.dart';

@RoutePage()
class CreateMovementScreen extends StatelessWidget {
  const CreateMovementScreen({
    super.key,
    this.selectedProduct,
    this.selectedFromWhere,
    this.isEditing = false,
    this.transferToEdit,
  }) : assert(
         // Убедимся, что если isEditing == true, то transferToEdit не null
         (isEditing && transferToEdit != null) ||
             (!isEditing && transferToEdit == null),
         'При isEditing == true необходимо передать transferToEdit. При isEditing == false transferToEdit должен быть null.',
       );

  final Product? selectedProduct;
  final Cabinet? selectedFromWhere;

  // Параметры для редактирования
  final bool isEditing;
  final Transfer? transferToEdit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: invAppBar(
        title: isEditing ? "Редактирование перемещения" : "Перемещение",
      ),
      body: BlocConsumer<TransferCubit, TransferState>(
        listener: (context, state) {},
        builder: (context, transferState) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                _MovementForm(
                  // Передаем параметры для создания, если не редактируем
                  initialProduct: isEditing ? null : selectedProduct,
                  initialFromWhere: isEditing ? null : selectedFromWhere,
                  // Передаем параметры для редактирования
                  isEditing: isEditing,
                  transferToEdit: transferToEdit,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MovementForm extends StatefulWidget {
  const _MovementForm({
    this.initialProduct,
    this.initialFromWhere,
    this.isEditing = false,
    this.transferToEdit,
  });

  final Product? initialProduct;
  final Cabinet? initialFromWhere;
  final bool isEditing;
  final Transfer? transferToEdit;

  @override
  _MovementFormState createState() => _MovementFormState();
}

class _MovementFormState extends State<_MovementForm> {
  final _formKey = GlobalKey<FormState>(); // <-- Ключ формы

  Product? selectedProduct;
  Cabinet? selectedFromWhere;
  Cabinet? selectedToWhere;
  String? selectedTime;
  String? selectedReason;

  // Переменная для хранения объекта Transfer при редактировании
  Transfer? editingTransfer;

  late Transfer transfer;

  // Для текстового поля "Причина"
  final _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.isEditing && widget.transferToEdit != null) {
      // Режим редактирования: инициализируем поля из объекта
      editingTransfer = widget.transferToEdit;
      _initializeFieldsFromTransfer(editingTransfer!);
    } else {
      // Режим создания: стандартная инициализация
      if (widget.initialProduct != null) {
        selectedProduct = widget.initialProduct;
        if (widget.initialFromWhere != null) {
          selectedFromWhere = widget.initialFromWhere;
        } else {
          _loadLastTransferLocation();
        }
      }
    }
  }

  // Новый метод для инициализации полей из объекта Transfer при редактировании
  void _initializeFieldsFromTransfer(Transfer transfer) {
    // Дата
    selectedTime = transfer.date;

    // Причина
    selectedReason = transfer.reason;
    _reasonController.text = transfer.reason ?? '';

    // Остальные поля (Product, Cabinets) нужно найти по имени/ID
    // Это требует загрузки данных Product и Cabinet в initState или didChangeDependencies
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _findAndSetProductAndCabinets(transfer);
    });
  }

  // Новый метод для поиска Product и Cabinets по данным Transfer
  Future<void> _findAndSetProductAndCabinets(Transfer transfer) async {
    final productCubit = context.read<ProductCubit>();
    final cabinetCubit = context.read<CabinetCubit>();

    Product? foundProduct;
    Cabinet? foundFromCabinet;
    Cabinet? foundToCabinet;

    // Поиск Product по inventoryItem (предполагаем, что это ID)
    if (productCubit.state is ProductLoadSuccess) {
      final products = (productCubit.state as ProductLoadSuccess).products;
      foundProduct = products.firstWhere(
        (p) => p.productId == transfer.inventoryItem,
        orElse: () => Product(), // или null, если не найден
      );
      if (foundProduct.productId == null)
        foundProduct = null; // Проверка на пустой объект
    }

    // Поиск Cabinets по имени
    if (cabinetCubit.state is CabinetLoadSuccess) {
      final cabinets = (cabinetCubit.state as CabinetLoadSuccess).cabinets;
      foundFromCabinet = cabinets.firstWhere(
        (c) => c.name == transfer.fromWhere,
        orElse: () => Cabinet(), // или null
      );
      if (foundFromCabinet.name == null) foundFromCabinet = null;

      foundToCabinet = cabinets.firstWhere(
        (c) => c.name == transfer.toWhere,
        orElse: () => Cabinet(), // или null
      );
      if (foundToCabinet.name == null) foundToCabinet = null;
    }

    // Обновляем состояние после поиска
    if (mounted) {
      setState(() {
        selectedProduct = foundProduct;
        selectedFromWhere = foundFromCabinet;
        selectedToWhere = foundToCabinet;
      });
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  // Метод для загрузки последнего места хранения
  Future<void> _loadLastTransferLocation() async {
    print('[==+==] Пытаемся найти Откуда');
    if (selectedProduct == null) return;

    final transferCubit = context.read<TransferCubit>();
    final lastTransfer = await transferCubit.getLastTransfer(
      selectedProduct!.productId!,
    );

    if (lastTransfer?.toWhere == null || !mounted) return;

    // Ищем кабинет по названию (точное совпадение или ближайшее)
    final cabinetCubit = context.read<CabinetCubit>();
    if (cabinetCubit.state is CabinetLoadSuccess) {
      final cabinets = (cabinetCubit.state as CabinetLoadSuccess).cabinets;
      final matchedCabinet = cabinets.firstWhere(
        (c) => c.name == lastTransfer!.toWhere,
      );
      if (mounted) {
        setState(() {
          selectedFromWhere = matchedCabinet;
        });
      }
    }
  }

  bool _validateFields() {
    if (selectedProduct == null ||
        selectedFromWhere == null ||
        selectedToWhere == null ||
        selectedTime == null ||
        selectedReason?.trim().isEmpty == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Заполните все поля')));
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      // <-- Оборачиваем в Form
      key: _formKey,
      child: BlocConsumer<TransferCubit, TransferState>(
        listener: (context, state) {
          if (state is TransferCreateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Перемещение успешно добавлено')),
            );
            context.router.push(MovementObjectRoute(transfer: transfer));
          }
          if (state is TransferUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Перемещение успешно обновлено')),
            );
            // Переход на экран деталей обновленного перемещения
            context.router.push(MovementObjectRoute(transfer: state.transfer));
            // Или pop(), если хотите вернуться назад
            // context.router.pop();
          }
          if (state is TransferFailure) {
            // Эвойдим лишний сникБар от getlast_transfer_for_object.php
            if (state.message.contains(
                  'Откуда: запись не найдена для инвентарного номера:',
                ) ==
                false) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Произошла ошибка, повторите позже...${state.message}',
                  ),
                ),
              );
            }
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              InputField(
                placeholder: 'Дата',
                date: true,
                initialValue: selectedTime,
                onChanged: (value) {
                  setState(() {
                    selectedTime = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Выберите дату';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              BlocBuilder<ProductCubit, ProductState>(
                builder: (context, productState) {
                  if (productState is ProductLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (productState is ProductLoadSuccess) {
                    final List<Product> products = productState.products;
                    return Column(
                      children: [
                        InputField(
                          selectedTitle: selectedProduct == null
                              ? "Выберите объект"
                              : selectedProduct!.name! +
                                    " - #" +
                                    selectedProduct!.productId!,
                          placeholder: 'Объект инвентаризации',
                          dropdownWithSearch: true,
                          onChanged: (_) {},
                          onTap: () async {
                            final selected = await showSearch<Product?>(
                              context: context,
                              delegate: ProductSearchDelegate(products),
                            );
                            if (selected != null &&
                                selected != selectedProduct) {
                              setState(() {
                                selectedProduct = selected;
                                selectedFromWhere =
                                    null; // Сбросим, пока не загрузим новое значение
                              });
                              _loadLastTransferLocation(); // Загружаем новое "откуда"
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              print('VALIDATOR WORKSSSSSSSSSSSSSSSS');
                              return 'Пожалуйста, выберите объект';
                            }
                            return null;
                          },
                        ),
                      ],
                    );
                  } else {
                    return const Text('Ошибка загрузки товаров - наименования');
                  }
                },
              ),
              const SizedBox(height: 16),
              BlocBuilder<CabinetCubit, CabinetState>(
                builder: (context, cabinetState) {
                  if (cabinetState is CabinetLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (cabinetState is CabinetLoadSuccess) {
                    final List<Cabinet> cabinets = cabinetState.cabinets;
                    return Column(
                      children: [
                        InputField(
                          placeholder: 'Откуда',
                          selectedTitle: selectedFromWhere == null
                              ? "Откуда"
                              : "${selectedFromWhere!.name} кабинет",
                          dropdownWithSearch: true,
                          onChanged: (_) {},
                          onTap: () async {
                            final selected = await showSearch<Cabinet?>(
                              context: context,
                              delegate: CabinetSearchDelegate(cabinets),
                            );
                            if (selected != null) {
                              setState(() {
                                selectedFromWhere = selected;
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Пожалуйста, выберите значение';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        InputField(
                          placeholder: 'Куда',
                          selectedTitle: selectedToWhere == null
                              ? "Куда"
                              : "${selectedToWhere!.name} кабинет",
                          dropdownWithSearch: true,
                          onChanged: (_) {},
                          onTap: () async {
                            final selected = await showSearch<Cabinet?>(
                              context: context,
                              delegate: CabinetSearchDelegate(cabinets),
                            );
                            if (selected != null) {
                              setState(() {
                                selectedToWhere = selected;
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Пожалуйста, выберите значение';
                            }
                            return null;
                          },
                        ),
                      ],
                    );
                  } else {
                    return const Text('Ошибка загрузки кабинетов');
                  }
                },
              ),
              const SizedBox(height: 12),
              InputField(
                placeholder: 'Причина',
                initialValue: widget.isEditing ? widget.transferToEdit!.reason : '',
                onChanged: (value) {
                  setState(() {
                    selectedReason = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите причину';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              mainButton(
                onPressed: () {
                  final transferCubit = context.read<TransferCubit>();
                  if (_formKey.currentState?.validate() == true &&
                      _validateFields()) {
                    transfer = Transfer(
                      id: widget.isEditing ? widget.transferToEdit!.id : null,
                      reason: selectedReason,
                      name: selectedProduct!.name,
                      toWhere: selectedToWhere!.name,
                      fromWhere: selectedFromWhere!.name,
                      inventoryItem: selectedProduct!.productId,
                      date: selectedTime!,
                      author:
                          "${context.read<UserCubit>().currentUser!.lastName} ${context.read<UserCubit>().currentUser!.firstName} ${context.read<UserCubit>().currentUser!.patronymic}",
                    );
                     if (widget.isEditing) {
                      // Вызываем метод обновления
                      transferCubit.updateTransfer(transfer);
                      context.read<NotificationCubit>().sendNotification(
                            title: 'Обновление перемещения',
                            body:
                                '${transfer.date} было зафиксировано обновление объекта с инвентарным номером ${transfer.inventoryItem} из кабинета ${transfer.fromWhere} в кабинет ${transfer.toWhere}, авторства ${transfer.author}',
                            destinationRoles: ['fho', 'admin'],
                          );
                      // Отправка уведомления при редактировании - решите, нужно ли
                      // context.read<NotificationCubit>().sendNotification(...);
                    } else {
                      // Вызываем метод создания
                      transferCubit.createTransfer(transfer);
                      context.read<NotificationCubit>().sendNotification(
                            title: 'Новое перемещение',
                            body:
                                '${transfer.date} было зафиксировано новое перемещение объекта с инвентарным номером ${transfer.inventoryItem} из кабинета ${transfer.fromWhere} в кабинет ${transfer.toWhere}, авторства ${transfer.author}',
                            destinationRoles: ['fho', 'admin'],
                          );
                    }
                  }
                },
                title: widget.isEditing ? "Сохранить изменения" : "Добавить перемещение",
              ),
              const SizedBox(height: 8),
              mainButton(
                onPressed: () => context.router.pop(),
                title: "Отмена",
                color: AppColor.secondButton,
              ),
            ],
          );
        },
      ),
    );
  }
}

class ProductSearchDelegate extends SearchDelegate<Product?> {
  final List<Product> products;

  ProductSearchDelegate(this.products);

  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: Navigator.of(context).pop,
  );

  @override
  Widget buildResults(BuildContext context) {
    final filtered = products
        .where((p) {
          final lowerQuery = query.toLowerCase();
          return p.name!.toLowerCase().contains(lowerQuery) ||
              p.productId!.toLowerCase().contains(lowerQuery);
        })
        .take(100)
        .toList();

    return _buildList(filtered);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filtered = products
        .where((p) {
          final lowerQuery = query.toLowerCase();
          return p.name!.toLowerCase().contains(lowerQuery) ||
              p.productId!.toLowerCase().contains(lowerQuery);
        })
        .take(100)
        .toList();

    return _buildList(filtered);
  }

  Widget _buildList(List<Product> list) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, i) {
        final product = list[i];
        return ListTile(
          tileColor: i % 2 == 0 ? AppColor.elementColor : Colors.transparent,
          title: Text(product.name!),
          subtitle: Text('ID: ${product.id}'),
          onTap: () {
            close(context, product);
          },
        );
      },
    );
  }
}

class CabinetSearchDelegate extends SearchDelegate<Cabinet?> {
  final List<Cabinet> cabinets;

  CabinetSearchDelegate(this.cabinets);

  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: Navigator.of(context).pop,
  );

  @override
  Widget buildResults(BuildContext context) {
    final filtered = cabinets
        .where(
          (c) => c.name?.toLowerCase().contains(query.toLowerCase()) ?? false,
        )
        .take(100)
        .toList();

    return _buildList(filtered);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filtered = cabinets
        .where(
          (c) => c.name?.toLowerCase().contains(query.toLowerCase()) ?? false,
        )
        .take(100)
        .toList();

    return _buildList(filtered);
  }

  Widget _buildList(List<Cabinet> list) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, i) {
        final cabinet = list[i];
        return ListTile(
          tileColor: i % 2 == 0 ? AppColor.elementColor : Colors.transparent,
          title: Text(cabinet.name ?? 'Без названия'),
          subtitle: Text(
            'Этаж: ${cabinet.cabinetFloor ?? 'Не указан'}, ID: ${cabinet.id}',
          ),
          onTap: () {
            close(context, cabinet);
          },
        );
      },
    );
  }
}
