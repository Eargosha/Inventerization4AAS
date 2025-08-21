import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventerization_4aas/cubit/transfer/transfer_cubit.dart';
import 'package:inventerization_4aas/models/product_model.dart';
import 'package:inventerization_4aas/models/transfer_model.dart';
import 'package:inventerization_4aas/router/route.dart';
import 'package:inventerization_4aas/screens/widgets/app_bar.dart';
import 'package:inventerization_4aas/screens/widgets/info_row.dart';
import 'package:inventerization_4aas/screens/widgets/main_button.dart';
import 'package:inventerization_4aas/constants/theme/app_text_styles.dart';
import 'package:inventerization_4aas/screens/widgets/transfers_history.dart';

@RoutePage()
class ObjectScreen extends StatefulWidget {
  final Product product;

  const ObjectScreen({super.key, required this.product});

  @override
  State<ObjectScreen> createState() => _ObjectScreenState();
}

class _ObjectScreenState extends State<ObjectScreen> {
  Transfer? lastTransferForObject;

  @override
  void initState() {
    super.initState();
    context.read<TransferCubit>().loadTransfers({
      'inventory_item': widget.product.productId,
    });
    getLastTransfer();
  }

  Future<void> getLastTransfer() async {
    final transfer = await context.read<TransferCubit>().getLastTransfer(
      widget.product.productId!,
    );
    if (mounted) {
      setState(() {
        lastTransferForObject = transfer;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: invAppBar(
        title: "Объект",
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
              const Divider(),
              InfoRow(label: 'Инв. номер', value: widget.product.productId!),
              const Divider(),
              InfoRow(label: 'Название', value: widget.product.name!),
              const Divider(),
              InfoRow(
                label: 'Сейчас в',
                value: lastTransferForObject == null
                    ? 'Нет информации'
                    : 'Кабинет ${lastTransferForObject?.toWhere}',
              ),
              const Divider(),
              InfoRow(
                label: 'Перенос был из',
                value: lastTransferForObject == null
                    ? 'Нет информации'
                    : 'Кабинет ${lastTransferForObject?.fromWhere}',
              ),
              SizedBox(height: 32),
              mainButton(
                title: 'Добавить перемещение',
                onPressed: () {
                  context.router.push(
                    CreateMovementRoute(selectedProduct: widget.product),
                  );
                },
              ),
              SizedBox(height: 32),
              Text(
                'История перемещений',
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
}
