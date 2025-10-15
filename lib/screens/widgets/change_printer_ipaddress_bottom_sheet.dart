// lib/screens/bottom_sheets/change_printer_ip_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:inventerization_4aas/constants/app_constants.dart';
import 'package:inventerization_4aas/constants/theme/app_colors.dart';
import 'package:inventerization_4aas/constants/theme/app_text_styles.dart';
import 'package:inventerization_4aas/repositories/printer_service.dart';
import 'package:inventerization_4aas/screens/widgets/input_field_widget.dart';
import 'package:inventerization_4aas/screens/widgets/main_button.dart';

class ChangePrinterIpBottomSheet extends StatefulWidget {
  const ChangePrinterIpBottomSheet({super.key});

  @override
  State<ChangePrinterIpBottomSheet> createState() =>
      _ChangePrinterIpBottomSheetState();
}

class _ChangePrinterIpBottomSheetState extends State<ChangePrinterIpBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _ipAddress;

  // Валидатор IP-адреса
  String? _validateIpAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите IP-адрес';
    }

    final ipRegex = RegExp(r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$');
    if (!ipRegex.hasMatch(value)) {
      return 'Неверный формат IP-адреса';
    }

    final parts = value.split('.');
    for (final part in parts) {
      final num = int.tryParse(part);
      if (num == null || num < 0 || num > 255) {
        return 'Каждое число должно быть от 0 до 255';
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _ipAddress = AppConstants.printerIpAddr; // берём текущий IP
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Настройка IP принтера',
                  style: AppTextStyle.style18w700.copyWith(
                    color: AppColor.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                // Поле ввода IP
                InputField(
                  placeholder: '192.168.1.100',
                  initialValue: _ipAddress,
                  onChanged: (value) {
                    _ipAddress = value ?? '';
                  },
                  validator: _validateIpAddress,
                ),
                const SizedBox(height: 24),

                // Кнопки
                Row(
                  children: [
                    Expanded(
                      child: mainButton(
                        title: 'Отмена',
                        color: AppColor.attentionColor,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: mainButton(
                        title: 'Сохранить',
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Сохраняем в SharedPreferences и обновляем AppConstants
                            PrinterIpService.savePrinterIp(_ipAddress);
                            // Уведомление
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('IP принтера обновлён на $_ipAddress'),
                                backgroundColor: AppColor.mainButton,
                              ),
                            );
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}