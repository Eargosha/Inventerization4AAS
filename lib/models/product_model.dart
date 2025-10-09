class Product {
  final String? id; // В БД это PRODUCT_ID, используется как ID
  final String? productId; // То же значение, что и id
  final String? name;
  final String? barcode;
  final String? rfid;

  Product({
    this.id,
    this.productId,
    this.name,
    this.barcode,
    this.rfid,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      barcode: json['barcode']?.toString() ?? '',
      rfid: json['rfid']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'barcode': barcode,
      'rfid': rfid,
    };
  }

  Product copyWith({
    String? id,
    String? productId,
    String? name,
    String? rgid,
    String? barcode,
  }) {
    return Product(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      rfid: rfid ?? this.rfid,
    );
  }

  @override
  String toString() {
    return 'Product{id: $id, productId: $productId, name: $name, barcode: $barcode, rfid: $rfid}';
  }
}