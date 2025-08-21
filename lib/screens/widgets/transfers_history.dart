// widgets/transfers_history.dart

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventerization_4aas/cubit/transfer/transfer_cubit.dart';
import 'package:inventerization_4aas/models/transfer_model.dart';
import 'package:inventerization_4aas/constants/theme/app_colors.dart';
import 'package:inventerization_4aas/router/route.dart';

class TransfersHistory extends StatelessWidget {
  /// Список перемещений можно передать напрямую (если уже загружен)
  /// Или оставить null — тогда виджет сам заберёт из Cubit'а
  final List<Transfer>? transfers;

  const TransfersHistory({super.key, this.transfers});

  @override
  Widget build(BuildContext context) {
    if (transfers != null) {
      return _buildHistoryList(transfers!, context);
    }

    // Если список не передан — слушаем TransferCubit
    return BlocBuilder<TransferCubit, TransferState>(
      builder: (context, state) {
        if (state is TransferLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TransferLoadSuccess) {
          return _buildHistoryList(state.transfers, context);
        } else {
          return const Center(
            child: Text('Не удалось загрузить историю перемещений'),
          );
        }
      },
    );
  }

  Widget _buildHistoryList(List<Transfer> transferList, BuildContext context) {
    // Копируем и сортируем по убыванию: новые — первыми
    final sortedTransfers = List<Transfer>.from(transferList)
      ..sort((a, b) {
        return b.date!.compareTo(a.date!); // b - a → убывание
      });

    final items = <Widget>[];

    for (final transfer in sortedTransfers) {
      // Событие "Приняли" — прибытие в кабинет
      if (transfer.toWhere != null) {
        items.add(
          _buildTransferTile(
            onPressed: () {context.router.push(MovementObjectRoute(transfer: transfer));},
            icon: Icons.check_circle,
            color: AppColor.aproveColor,
            title: 'Приняли в кабинет ${transfer.toWhere}',
            date: transfer.date!,
            objectName: transfer.name!,
          ),
        );
      }

      // Событие "Отдали" — убытие из кабинета
      if (transfer.fromWhere != null) {
        items.add(
          _buildTransferTile(
            onPressed: () {context.router.push(MovementObjectRoute(transfer: transfer));},
            icon: Icons.arrow_circle_up,
            color: AppColor.attentionColor,
            title: 'Отдали из кабинета ${transfer.fromWhere}',
            date: transfer.date!,
            objectName: transfer.name!,
          ),
        );
      }
    }

    if (items.isEmpty) {
      items.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'История перемещений пуста',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(children: items);
  }

  Widget _buildTransferTile({
    required void Function()? onPressed,
    required IconData icon,
    required Color color,
    required String title,
    required String date,
    required String objectName,
  }) {
    return Column(
      children: [
        ListTile(
          onTap: onPressed!,
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
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text('$date, $objectName'),
        ),
        const Divider(),
      ],
    );
  }
}
