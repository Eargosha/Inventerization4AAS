import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

// Модели
import 'package:inventerization_4aas/models/product_model.dart'; // Или нужный путь
import 'package:inventerization_4aas/models/api_response_model.dart'; // Предполагается, что он у тебя уже есть

// Репозитории
import 'package:inventerization_4aas/repositories/product_repository.dart'; // Укажи свой репозиторий

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository productRepository;

  ProductCubit({required this.productRepository}) : super(ProductInitial());

  /// Загружает список продуктов с сервера
  Future<void> loadProducts() async {
    emit(ProductLoading());

    try {
      final ApiResponse response = await productRepository.loadProducts();

      if (response.success && response.data is List) {
        final List<Product> products = (response.data as List)
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();

        print("[==+==] Загрузили обьекты инвентаризации, вот один из них: ${products[0].toString()}");

        emit(ProductLoadSuccess(products: products, message: response.message!));
      } else {
        emit(ProductFailure(response.message ?? 'Не удалось загрузить список товаров'));
      }
    } catch (e) {
      emit(ProductFailure('Ошибка сети: $e'));
    }
  }
}