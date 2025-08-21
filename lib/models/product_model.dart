class Product {
  final String? id; // В БД это PRODUCT_ID, используется как ID
  final String? productId; // То же значение, что и id
  final String? name;
  final String? barcode;

  Product({
    this.id,
    this.productId,
    this.name,
    this.barcode,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      barcode: json['barcode']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'barcode': barcode,
    };
  }

  Product copyWith({
    String? id,
    String? productId,
    String? name,
    String? barcode,
  }) {
    return Product(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
    );
  }

  @override
  String toString() {
    return 'Product{id: $id, productId: $productId, name: $name, barcode: $barcode}';
  }
}