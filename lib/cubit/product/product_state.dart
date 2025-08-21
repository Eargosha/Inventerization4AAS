part of 'product_cubit.dart';

@immutable
abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoadSuccess extends ProductState {
  final List<Product> products;
  final String message;

  ProductLoadSuccess({required this.products, this.message = 'Данные успешно загружены'});
}

class ProductFailure extends ProductState {
  final String message;

  ProductFailure(this.message);
}