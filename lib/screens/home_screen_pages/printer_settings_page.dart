import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventerization_4aas/constants/app_constants.dart';
import 'package:inventerization_4aas/constants/theme/app_colors.dart';
import 'package:inventerization_4aas/constants/theme/app_text_styles.dart';
import 'package:inventerization_4aas/cubit/printer/printer_cubit.dart';
import 'package:inventerization_4aas/screens/widgets/app_bar.dart';
import 'package:inventerization_4aas/screens/widgets/checkbox.dart';
import 'package:inventerization_4aas/screens/widgets/input_field_widget.dart';
import 'package:inventerization_4aas/screens/widgets/main_button.dart';

@RoutePage()
class PrinterSettingsScreen extends StatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

bool selectedAntennaPlacement = false;

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Тип этикетки
  String? selectedLabelType;

  // Контроллеры для всех полей
  String? _lengthValue;
  String? _widthValue;
  String? _antennaXValue;
  String? _antennaYValue;
  String? _powerWriteValue;
  String? _powerReadValue;
  String? _stepSizeValue;

  @override
  void initState() {
    super.initState();
    // Устанавливаем значения по умолчанию для "обычной" этикетки
    _setDefaultsForLabelType('Обычная');
  }

  void _setDefaultsForLabelType(String type) {
    setState(() {
      selectedLabelType = type;
      final defaults = AppConstants.labelTypeDefaults[type]!;
      _lengthValue = defaults['length']!;
      _widthValue = defaults['width']!;
      _antennaXValue = defaults['antennaX']!;
      _antennaYValue = defaults['antennaY']!;
      _powerWriteValue = defaults['powerWrite']!;
      _powerReadValue = defaults['powerRead']!;
      _stepSizeValue = defaults['stepSize']!;
      selectedAntennaPlacement = bool.tryParse(
        defaults['selectedAntennaPlacement']!,
      )!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: BlocConsumer<PrinterStatusCubit, PrinterStatusState>(
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
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: invAppBar(title: 'Настройки печати'),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          key: ValueKey(selectedLabelType),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 16),
                            Text(
                              'Быстро - по типу этикетки',
                              style: AppTextStyle.style22w700,
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(height: 8),
                            InputField(
                              placeholder: 'Выберите тип',
                              dropdownWithSearch: true,
                              onChanged: (_) {},
                              dropdownItems: ["Обычная", "Металлическая"],
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Выберите тип этикетки'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          title: Text('Обычная'),
                                          onTap: () {
                                            _setDefaultsForLabelType('Обычная');
                                            Navigator.pop(context);
                                          },
                                        ),
                                        ListTile(
                                          title: Text('Металлическая'),
                                          onTap: () {
                                            _setDefaultsForLabelType(
                                              'Металлическая',
                                            );
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              validator: (value) {
                                if (selectedLabelType == null) {
                                  return 'Пожалуйста, выберите тип этикетки';
                                }
                                return null;
                              },
                              selectedTitle: selectedLabelType != null
                                  ? selectedLabelType
                                  : null,
                            ),
                            SizedBox(height: 24),
                            Text(
                              'Размер этикетки',
                              style: AppTextStyle.style22w700,
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Длина (мм)',
                                        style: AppTextStyle.style14w600,
                                        textAlign: TextAlign.left,
                                      ),
                                      InputField(
                                        placeholder: '',
                                        initialValue: _lengthValue,
                                        onChanged: (value) {
                                          _lengthValue = value;
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Введите длину';
                                          }
                                          final numVal = double.tryParse(value);
                                          if (numVal == null ||
                                              numVal < 0 ||
                                              numVal > 240) {
                                            return 'Длина должна быть от 0 до 240 мм';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ширина (мм)',
                                        style: AppTextStyle.style14w600,
                                        textAlign: TextAlign.left,
                                      ),
                                      InputField(
                                        initialValue: _widthValue,
                                        placeholder: '',
                                        onChanged: (value) {
                                          _widthValue = value;
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Введите ширину';
                                          }
                                          final numVal = double.tryParse(value);
                                          if (numVal == null ||
                                              numVal < 0 ||
                                              numVal > 240) {
                                            return 'Ширина должна быть от 0 до 240 мм';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Настройки RFID',
                              style: AppTextStyle.style22w700,
                              textAlign: TextAlign.left,
                            ),
                  
                            Text(
                              'Положение антенны',
                              style: AppTextStyle.style16w600,
                              textAlign: TextAlign.left,
                            ),
                            Row(
                              children: [
                                invCheckbox(
                                  text: 'Переднее',
                                  value: selectedAntennaPlacement,
                                  onChanged: (newb) {
                                    setState(() {
                                      print(
                                        'Состояние чекбокса сейчас: $selectedAntennaPlacement',
                                      );
                  
                                      selectedAntennaPlacement = newb;
                                    });
                                  },
                                ),
                                invCheckbox(
                                  text: 'Нормальное',
                                  value: !selectedAntennaPlacement,
                                  onChanged: (newb) {
                                    setState(() {
                                      print(
                                        'Состояние чекбокса сейчас: $selectedAntennaPlacement',
                                      );
                                      selectedAntennaPlacement = !newb;
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Антенна по X (мм)',
                                        style: AppTextStyle.style14w600,
                                        textAlign: TextAlign.left,
                                      ),
                                      InputField(
                                        initialValue: _antennaXValue,
                                        placeholder: '',
                                        onChanged: (value) {
                                          _antennaXValue = value;
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Введите положение по X';
                                          }
                                          final numVal = double.tryParse(value);
                                          if (numVal == null ||
                                              numVal < 0 ||
                                              numVal > 36) {
                                            return 'X должен быть от 0 до 36 мм';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Антенна по Y (мм)',
                                        style: AppTextStyle.style14w600,
                                        textAlign: TextAlign.left,
                                      ),
                                      InputField(
                                        initialValue: _antennaYValue,
                                        placeholder: '',
                                        onChanged: (value) {
                                          _antennaYValue = value;
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Введите положение по Y';
                                          }
                                          final numVal = double.tryParse(value);
                                          if (numVal == null ||
                                              numVal < 0 ||
                                              numVal > 30) {
                                            return 'Y должен быть от 0 до 30 мм';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Питание - запись (dBm)',
                                        style: AppTextStyle.style14w600,
                                        textAlign: TextAlign.left,
                                      ),
                                      InputField(
                                        initialValue: _powerWriteValue,
                                        placeholder: '',
                                        onChanged: (value) {
                                          _powerWriteValue = value;
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Введите питание при записи';
                                          }
                                          final numVal = double.tryParse(value);
                                          if (numVal == null ||
                                              numVal < 0 ||
                                              numVal > 30) {
                                            return 'Питание записи должно быть от 0 до 30 dBm';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Питание - чтение (dBm)',
                                        style: AppTextStyle.style14w600,
                                        textAlign: TextAlign.left,
                                      ),
                                      InputField(
                                        initialValue: _powerReadValue,
                                        placeholder: '',
                                        onChanged: (value) {
                                          _powerReadValue = value;
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Введите питание при чтении';
                                          }
                                          final numVal = double.tryParse(value);
                                          if (numVal == null ||
                                              numVal < 0 ||
                                              numVal > 30) {
                                            return 'Питание чтения должно быть от 0 до 30 dBm';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Размер шага (mm)',
                                  style: AppTextStyle.style14w600,
                                  textAlign: TextAlign.left,
                                ),
                                InputField(
                                  initialValue: _stepSizeValue,
                                  placeholder: '',
                                  onChanged: (value) {
                                    _stepSizeValue = value;
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Введите размер шага';
                                    }
                                    final numVal = double.tryParse(value);
                                    if (numVal == null ||
                                        numVal < 1 ||
                                        numVal > 240) {
                                      return 'Размер шага должен быть от 1 до 240 мм';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                            mainButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Отправляем данные в кубит
                              context
                                  .read<PrinterStatusCubit>()
                                  .configurePrinter(
                                    labelLength: double.parse(_lengthValue!),
                                    labelWidth: double.parse(_widthValue!),
                                    isFrontAntenna: selectedAntennaPlacement,
                                    antennaX: double.parse(_antennaXValue!),
                                    antennaY: double.parse(_antennaYValue!),
                                    powerWrite: double.parse(_powerWriteValue!),
                                    powerRead: double.parse(_powerReadValue!),
                                    pitchSize: double.parse(_stepSizeValue!),
                                  );
                  
                              // Логгирование можно оставить, но не обязательно
                              final data = {
                                'labelType': selectedLabelType,
                                'length': double.parse(_lengthValue!),
                                'width': double.parse(_widthValue!),
                                'antennaX': double.parse(_antennaXValue!),
                                'antennaY': double.parse(_antennaYValue!),
                                'powerWrite': double.parse(_powerWriteValue!),
                                'powerRead': double.parse(_powerReadValue!),
                                'stepSize': double.parse(_stepSizeValue!),
                                'antennaPlacement': selectedAntennaPlacement
                                    ? 'переднее'
                                    : 'нормальное',
                              };
                              print('Данные для отправки: $data');
                            }
                          },
                          title: 'Применить настройки',
                        ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
