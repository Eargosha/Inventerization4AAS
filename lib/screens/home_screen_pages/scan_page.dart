// scan_screen.dart

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventerization_4aas/cubit/product/product_cubit.dart';
import 'package:inventerization_4aas/models/product_model.dart';
import 'package:inventerization_4aas/router/route.dart';
import 'package:inventerization_4aas/screens/widgets/barcode_scaner_overlay_screen.dart';
import 'package:inventerization_4aas/screens/widgets/rounded_button.dart';
import 'package:inventerization_4aas/constants/theme/app_colors.dart';
import 'package:inventerization_4aas/constants/theme/app_text_styles.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  String _scanBarcode = "Не распознано";

  // Функция открытия сканера
  // Future<void> _openScanner() async {
  //   final result = await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => const BarcodeScannerOverlayScreen(),
  //     ),
  //   );

  //   if (result != null && result is String) {
  //     setState(() {
  //       _scanBarcode = result;
  //       handleBarcodeScan(_scanBarcode, context);
  //       print("Результат сканирования баркода: $_scanBarcode");
  //     });
  //   }
  // }
  Future<void> _openScanner() async {
    final barcodeResult = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerOverlayScreen(),
      ),
    );

    print("[==+==] Получил результат по баркоду до проверки: $barcodeResult");

    if (barcodeResult != null) {
      print("[==+==] Получил результат по баркоду: $barcodeResult");
      handleBarcodeScan(barcodeResult, context);
    }
  }

  void handleBarcodeScan(String barcode, BuildContext context) {
    final state = context.read<ProductCubit>().state;

    if (state is ProductLoadSuccess) {
      final product = state.products.firstWhere(
        (p) => p.barcode == barcode,
        orElse: () => Product(id: '', productId: '', name: '', barcode: ''),
      );

      if (product.barcode!.isNotEmpty) {
        // Совпадение найдено — переходим на страницу объекта
        context.router.push(ObjectRoute(product: product));
      } else {
        // Совпадение не найдено
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Не найдено совпадений для баркода: $barcode"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Список продуктов не загружен
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Список продуктов ещё не загружен"),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) => Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            // Padding(
            //   padding: const EdgeInsets.symmetric(
            //     horizontal: 64.0,
            //     vertical: 32,
            //   ),
            //   child: mainButton(onPressed: () {}, title: "Ввести вручную"),
            // ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Можно просто навести камеру на штрих-код для получения информации',
                      style: AppTextStyle.style20w400.copyWith(
                        color: AppColor.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Кнопка запуска сканирования
                  roundedButton(onPressed: _openScanner, size: 20),

                  const SizedBox(height: 24),

                  // Отображение результата
                  if (_scanBarcode != "Не распознано")
                    Text(
                      "Результат: $_scanBarcode",
                      style: AppTextStyle.style16w600.copyWith(
                        color: AppColor.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
