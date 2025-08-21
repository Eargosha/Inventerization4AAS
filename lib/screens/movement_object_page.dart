import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventerization_4aas/cubit/transfer/transfer_cubit.dart';
import 'package:inventerization_4aas/models/transfer_model.dart';
import 'package:inventerization_4aas/router/route.dart';
import 'package:inventerization_4aas/screens/widgets/app_bar.dart';
import 'package:inventerization_4aas/screens/widgets/info_row.dart';
import 'package:inventerization_4aas/screens/widgets/main_button.dart';
import 'package:inventerization_4aas/constants/theme/app_colors.dart';
import 'package:inventerization_4aas/constants/theme/app_text_styles.dart';
import 'package:inventerization_4aas/screens/widgets/transfers_history.dart';

@RoutePage()
class MovementObjectScreen extends StatefulWidget {
  final Transfer transfer;

  const MovementObjectScreen({super.key, required this.transfer});

  @override
  State<MovementObjectScreen> createState() => _MovementObjectScreenState();
}

class _MovementObjectScreenState extends State<MovementObjectScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TransferCubit>().loadTransfers({
      'inventory_item': widget.transfer.inventoryItem,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: invAppBar(
        title: "Перемещение",
        leading: IconButton(
          onPressed: () {
            context.router.popUntilRoot();
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text(
                'Общая информация',
                style: AppTextStyle.style22w700,
                textAlign: TextAlign.left,
              ),
              Divider(),
              InfoRow(
                label: 'Инв. номер',
                value: widget.transfer.inventoryItem ?? '',
              ),
              Divider(),
              InfoRow(label: 'Название', value: widget.transfer.name ?? ''),
              Divider(),
              InfoRow(
                label: 'Дата создания',
                value: widget.transfer.date ?? '',
              ),
              Divider(),
              InfoRow(
                label: 'Перенос в',
                value: 'Кабинет ${widget.transfer.toWhere ?? ""}',
              ),
              Divider(),
              InfoRow(
                label: 'Перенос из',
                value: 'Кабинет ${widget.transfer.fromWhere ?? ""}',
              ),
              Divider(),
              InfoRow(
                label: 'Создатель переноса',
                value: widget.transfer.author ?? '',
              ),
              Divider(),
              InfoRow(label: 'Причина', value: widget.transfer.reason ?? ''),
              Divider(),
              SizedBox(height: 8),
              mainButton(
                onPressed: () {
                  context.router.push(
                    CreateMovementRoute(
                      isEditing: true,
                      transferToEdit: widget.transfer,
                    ),
                  );
                },
                title: 'Редактировать',
              ),
              mainButton(
                onPressed: () {
                  showBottomSheet(context: context, builder: (context) {
                    return _buildConfirmForm(context);
                  });
                },
                title: 'Удалить',
              ),
              SizedBox(height: 8),
              Text(
                'История',
                style: AppTextStyle.style22w700,
                textAlign: TextAlign.left,
              ),
              TransfersHistory(),

              SizedBox(height: 16),
              // В светлом будущем
              // Text('Фотографии', style: AppTextStyle.style22w700),
              // Container(
              //   height: 250,
              //   child: Column(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       Text(
              //         'У обьекта нет фотографий',
              //         style: AppTextStyle.style16w400,
              //       ),
              //       mainButton(
              //         onPressed: () {},
              //         title: "Добавить",
              //         color: AppColor.secondButton,
              //       ),
              //     ],
              //   ),
              // ),
              // SizedBox(height: 16),
              // mainButton(onPressed: () {}, title: "История изменений"),
            ],
          ),
        ),
      ),
    );
  }

    Widget _buildConfirmForm(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight / 2, // Занимает половину высоты экрана
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Text('Подтвердите удаление', style: AppTextStyle.style18w700),
          const SizedBox(height: 40),
          mainButton(
            onPressed: () {
              context.read<TransferCubit>().deleteTransfer(widget.transfer.id!);
              Navigator.of(context).pop();
            },
            title: "Да",
          ),
          mainButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            title: "Нет",
            color: AppColor.aproveColor,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
