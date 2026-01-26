import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventerization_4aas/constants/app_constants.dart';
import 'package:inventerization_4aas/constants/theme/app_colors.dart';
import 'package:inventerization_4aas/constants/theme/app_text_styles.dart';
import 'package:inventerization_4aas/cubit/printer/printer_cubit.dart';
import 'package:inventerization_4aas/cubit/product/product_cubit.dart';
import 'package:inventerization_4aas/models/product_model.dart';
import 'package:inventerization_4aas/screens/create_movement_page.dart';
import 'package:inventerization_4aas/screens/widgets/input_field_widget.dart';
import 'package:inventerization_4aas/screens/widgets/main_button.dart';
import 'package:inventerization_4aas/screens/widgets/printing_status.dart';

class PrinterScreen extends StatefulWidget {
  const PrinterScreen({super.key});

  @override
  State<PrinterScreen> createState() => _PrinterScreenState();
}

enum LabelType {
  regular,
  metallic;

  String get label {
    switch (this) {
      case LabelType.regular:
        return 'Обычная';
      case LabelType.metallic:
        return 'Металлическая';
    }
  }
}

class _PrinterScreenState extends State<PrinterScreen> {
  Product? selectedProduct;
  LabelType?
  selectedLabelType; // по умолчанию — никакая, заставляем пользователя задуматься

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PrinterStatusCubit, PrinterStatusState>(
      listener: (context, state) {
        if (state is PrinterConfiguring) {
          // Показываем "загрузку"
          if (!context.mounted) return;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Настраиваем принтер...',
                      softWrap: true,
                      overflow:
                          TextOverflow.visible, // или ellipsis, если хочешь
                      style: AppTextStyle.style16w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state is PrinterConfigurationSuccess) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              backgroundColor: AppColor.aproveColor,
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Готово!', softWrap: true),
                ],
              ),
            ),
          );
          // Убираем диалог загрузки
          Navigator.of(context).pop(); // закрываем индикатор

          // Показываем успех
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );

          // Через короткую задержку — возвращаемся назад
          Future.delayed(const Duration(milliseconds: 800), () {
            if (context.mounted) {
              context.router.pop(); // AutoRoute: pop на один экран
            }
          });
        } else if (state is PrinterConfigurationFailure) {
          // Убираем диалог загрузки
          Navigator.of(context).pop();

          // Показываем ошибку
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, asyncSnapshot) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // mainButton(
                  //   onPressed: () {
                  //     context.router.push(PrinterSettingsRoute());
                  //   },
                  //   title: 'Настроить принтер',
                  //   color: AppColor.elementColor,
                  // ),
                  SizedBox(height: 16),
                  Text(
                    'Выберите тип этикетки и объект учета',
                    style: AppTextStyle.style16w600,
                  ),

                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.start,
                  //   children: [
                  //     Text('Обычная', style: AppTextStyle.style16w400),
                  //     Radio<LabelType>(
                  //       value: LabelType.regular,
                  //       groupValue: selectedLabelType,
                  //       onChanged: (value) {
                  //         setState(() => selectedLabelType = value!);
                  //         final defaults =
                  //             AppConstants.labelTypeDefaults['Обычная']!;
                  //         context.read<PrinterStatusCubit>().configurePrinter(
                  //           labelLength: double.parse(defaults['length']!),
                  //           labelWidth: double.parse(defaults['width']!),
                  //           isFrontAntenna: false,
                  //           antennaX: double.parse(defaults['antennaX']!),
                  //           antennaY: double.parse(defaults['antennaY']!),
                  //           powerWrite: double.parse(defaults['powerWrite']!),
                  //           powerRead: double.parse(defaults['powerRead']!),
                  //           pitchSize: double.parse(defaults['stepSize']!),
                  //         );
                  //       },
                  //     ),
                  //     Text('Металлическая', style: AppTextStyle.style16w400),
                  //     Radio<LabelType>(
                  //       value: LabelType.metallic,
                  //       groupValue: selectedLabelType,
                  //       onChanged: (value) {
                  //         setState(() => selectedLabelType = value!);
                  //         final metallic =
                  //             AppConstants.labelTypeDefaults['Металлическая']!;
                  //         context.read<PrinterStatusCubit>().configurePrinter(
                  //           labelLength: double.parse(metallic['length']!),
                  //           labelWidth: double.parse(metallic['width']!),
                  //           isFrontAntenna: true,
                  //           antennaX: double.parse(metallic['antennaX']!),
                  //           antennaY: double.parse(metallic['antennaY']!),
                  //           powerWrite: double.parse(metallic['powerWrite']!),
                  //           powerRead: double.parse(metallic['powerRead']!),
                  //           pitchSize: double.parse(metallic['stepSize']!),
                  //         );
                  //       },
                  //     ),
                  //   ],
                  // ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.start,
                  //   children: [
                  //     GestureDetector(
                  //       onTap: () {
                  //         final newValue = LabelType.regular;
                  //         if (selectedLabelType != newValue) {
                  //           setState(() => selectedLabelType = newValue);
                  //           final defaults =
                  //               AppConstants.labelTypeDefaults['Обычная']!;
                  //           context.read<PrinterStatusCubit>().configurePrinter(
                  //             labelLength: double.parse(defaults['length']!),
                  //             labelWidth: double.parse(defaults['width']!),
                  //             isFrontAntenna: false,
                  //             antennaX: double.parse(defaults['antennaX']!),
                  //             antennaY: double.parse(defaults['antennaY']!),
                  //             powerWrite: double.parse(defaults['powerWrite']!),
                  //             powerRead: double.parse(defaults['powerRead']!),
                  //             pitchSize: double.parse(defaults['stepSize']!),
                  //           );
                  //         }
                  //       },
                  //       child: Row(
                  //         mainAxisSize: MainAxisSize.min,
                  //         children: [
                  //           Text('Обычная', style: AppTextStyle.style16w400),
                  //           Radio<LabelType>(
                  //             value: LabelType.regular,
                  //             groupValue: selectedLabelType,
                  //             onChanged: (value) {
                  //               // Этот onChanged всё равно будет вызван при клике на сам Radio
                  //               // Но если вы используете GestureDetector — можно оставить его пустым
                  //               // или удалить, если не нужно дублирование
                  //             },
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //     GestureDetector(
                  //       onTap: () {
                  //         final newValue = LabelType.metallic;
                  //         if (selectedLabelType != newValue) {
                  //           setState(() => selectedLabelType = newValue);
                  //           final metallic = AppConstants
                  //               .labelTypeDefaults['Металлическая']!;
                  //           context.read<PrinterStatusCubit>().configurePrinter(
                  //             labelLength: double.parse(metallic['length']!),
                  //             labelWidth: double.parse(metallic['width']!),
                  //             isFrontAntenna: true,
                  //             antennaX: double.parse(metallic['antennaX']!),
                  //             antennaY: double.parse(metallic['antennaY']!),
                  //             powerWrite: double.parse(metallic['powerWrite']!),
                  //             powerRead: double.parse(metallic['powerRead']!),
                  //             pitchSize: double.parse(metallic['stepSize']!),
                  //           );
                  //         }
                  //       },
                  //       child: Row(
                  //         mainAxisSize: MainAxisSize.min,
                  //         children: [
                  //           Text(
                  //             'Металлическая',
                  //             style: AppTextStyle.style16w400,
                  //           ),
                  //           Radio<LabelType>(
                  //             value: LabelType.metallic,
                  //             groupValue: selectedLabelType,
                  //             onChanged: (value) {},
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Обычная', style: AppTextStyle.style16w400),
                          Radio<LabelType>(
                            value: LabelType.regular,
                            groupValue: selectedLabelType,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => selectedLabelType = value);
                                final defaults =
                                    AppConstants.labelTypeDefaults['Обычная']!;
                                context
                                    .read<PrinterStatusCubit>()
                                    .configurePrinter(
                                      labelLength: double.parse(
                                        defaults['length']!,
                                      ),
                                      labelWidth: double.parse(
                                        defaults['width']!,
                                      ),
                                      isFrontAntenna: false,
                                      antennaX: double.parse(
                                        defaults['antennaX']!,
                                      ),
                                      antennaY: double.parse(
                                        defaults['antennaY']!,
                                      ),
                                      powerWrite: double.parse(
                                        defaults['powerWrite']!,
                                      ),
                                      powerRead: double.parse(
                                        defaults['powerRead']!,
                                      ),
                                      pitchSize: double.parse(
                                        defaults['stepSize']!,
                                      ),
                                    );
                              }
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Металлическая',
                            style: AppTextStyle.style16w400,
                          ),
                          Radio<LabelType>(
                            value: LabelType.metallic,
                            groupValue: selectedLabelType,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => selectedLabelType = value);
                                final metallic = AppConstants
                                    .labelTypeDefaults['Металлическая']!;
                                context
                                    .read<PrinterStatusCubit>()
                                    .configurePrinter(
                                      labelLength: double.parse(
                                        metallic['length']!,
                                      ),
                                      labelWidth: double.parse(
                                        metallic['width']!,
                                      ),
                                      isFrontAntenna: true,
                                      antennaX: double.parse(
                                        metallic['antennaX']!,
                                      ),
                                      antennaY: double.parse(
                                        metallic['antennaY']!,
                                      ),
                                      powerWrite: double.parse(
                                        metallic['powerWrite']!,
                                      ),
                                      powerRead: double.parse(
                                        metallic['powerRead']!,
                                      ),
                                      pitchSize: double.parse(
                                        metallic['stepSize']!,
                                      ),
                                    );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
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
                                  });
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  // print('VALIDATOR WORKSSSSSSSSSSSSSSSS');
                                  return 'Пожалуйста, выберите объект';
                                }
                                return null;
                              },
                            ),
                          ],
                        );
                      } else {
                        return const Text(
                          'Ошибка загрузки товаров - наименования',
                        );
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  mainButton(
                    onPressed: () {
                      if (selectedLabelType == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColor.attentionColor,
                            content: Text(
                              'Пожалуйста, выберите тип этикетки для печати',
                            ),
                          ),
                        );
                        return;
                      }
                      if (selectedProduct == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColor.attentionColor,
                            content: Text(
                              'Пожалуйста, выберите объект для печати',
                            ),
                          ),
                        );
                        return;
                      }
                      int type = selectedLabelType == LabelType.regular ? 0 : 1;
                      context.read<PrinterStatusCubit>().printLabel(
                        selectedProduct!,
                        type,
                      );
                    },
                    title: 'Произвести печать',
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Статус операций',
                        style: AppTextStyle.style22w700,
                        textAlign: TextAlign.left,
                      ),
                      IconButton(
                        onPressed: () {
                          context
                              .read<PrinterStatusCubit>()
                              .getPrinterNetworkStatus();
                        },
                        icon: Icon(Icons.replay_outlined),
                      ),
                    ],
                  ),
                  PrinterStatusWidget(context: context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
