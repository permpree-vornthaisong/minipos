import 'package:equatable/equatable.dart';

class SaleItem extends Equatable {
  final String productId;
  final String name;
  final double price;
  final int qty;

  const SaleItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.qty,
  });

  // copy แล้วเปลี่ยนแค่บาง field (เช่น เปลี่ยน qty)
  SaleItem copyWith({int? qty}) {
    return SaleItem(
      productId: productId,
      name: name,
      price: price,
      qty: qty ?? this.qty,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'qty': qty,
    };
  }

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      productId: json['productId'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      qty: json['qty'] as int,
    );
  }

  @override
  List<Object?> get props => [productId, name, price, qty];
}