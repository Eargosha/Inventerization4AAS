// widgets/printer_status_widget.dart (лучше переименовать файл)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventerization_4aas/constants/theme/app_colors.dart';
import 'package:inventerization_4aas/constants/theme/app_text_styles.dart';
import 'package:inventerization_4aas/cubit/printer/printer_cubit.dart';

class PrinterStatusWidget extends StatelessWidget {
  const PrinterStatusWidget({super.key, required BuildContext context});

  @override
  Widget build(context) {
    return BlocBuilder<PrinterStatusCubit, PrinterStatusState>(
      builder: (context, state) {
        // Сначала проверяем состояние получения сетевого статуса
        if (state is PrinterNetworkStatusLoading) {
          return const Center(
            child: LinearProgressIndicator(
              color: AppColor.mainButton,
              minHeight: 1,
            ),
          );
        } else if (state is PrinterNetworkStatusLoadSuccess) {
          return _buildNetworkStatusTile(
            isOnline: state.isOnline,
            lastChecked: DateTime.now(),
          );
        } else if (state is PrinterNetworkStatusFailure) {
          return _buildErrorTile(message: state.message);
        }
        // Затем проверяем состояние печати
        else if (state is PrinterLabelPrinting) {
          return _buildPrinterStatusTile(
            context: context,
            icon: Icons.print_outlined,
            color: AppColor.accentColor,
            title: 'Печать...',
            date: DateTime.now(),
            description: 'Отправка задания на принтер',
          );
        } else if (state is PrinterLabelPrintSuccess) {
          return _buildPrinterStatusTile(
            context: context,
            icon: Icons.download_done,
            color: AppColor.aproveColor,
            title: 'Печать успешна',
            date: DateTime.now(),
            description: state.message,
          );
        } else if (state is PrinterLabelPrintFailure) {
          return _buildPrinterStatusTile(
            context: context,
            icon: Icons.error_outline_outlined,
            color: AppColor.attentionColor,
            title: 'Ошибка печати',
            date: DateTime.now(),
            description: state.message,
          );
        } else if (state is PrinterLabelPrintAttention) {
          return _buildPrinterStatusTile(
            context: context,
            icon: Icons.warning,
            color: AppColor.warningColor,
            title: 'Печать прошла, но с ошибкой',
            date: DateTime.now(),
            description: state.message,
          );
        }
        
        // Начальное состояние — запрашиваем статус
        else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<PrinterStatusCubit>().getPrinterNetworkStatus();
          });
          return const Center(child: Text('Проверка статуса принтера...'));
        }
      },
    );
  }

  Widget _buildNetworkStatusTile({
    required bool isOnline,
    required DateTime lastChecked,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            decoration: BoxDecoration(
              color: isOnline ? AppColor.aproveColor : AppColor.attentionColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                isOnline ? Icons.print : Icons.print_disabled_outlined,
                color: Colors.white,
              ),
            ),
          ),
          title: Text(
            isOnline ? 'Принтер в сети' : 'Принтер не в сети',
            style: AppTextStyle.style14w600,
          ),
          subtitle: Text(
            isOnline
                ? 'Принтер готов к печати'
                : 'Проверьте подключение к принтеру',
            style: AppTextStyle.style14w400,
          ),
          trailing: Text(
            '${lastChecked.hour}:${lastChecked.minute.toString().padLeft(2, '0')}',
            style: AppTextStyle.style14w400,
          ),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildPrinterStatusTile({
    required IconData icon,
    required Color color,
    required String title,
    required DateTime date,
    required String description,
    required BuildContext context,
  }) {
    return Column(
      children: [
        ListTile(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Подробнее'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(description, style: AppTextStyle.style14w400)
                  ],
                ),
              ),
            );
          },
          leading: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(icon, color: Colors.white),
            ),
          ),
          title: Text(title, style: AppTextStyle.style16w400),
          subtitle: Text(description, style: AppTextStyle.style14w400),
          trailing: Text(
            '${date.hour}:${date.minute.toString().padLeft(2, '0')}',
            style: AppTextStyle.style14w400,
          ),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildErrorTile({required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: const Icon(
              Icons.error,
              color: AppColor.attentionColor,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColor.attentionColor),
          ),
        ],
      ),
    );
  }
}
