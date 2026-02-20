import 'package:equatable/equatable.dart';
import 'package:minipos/models/product.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

// โหลดสินค้าทั้งหมดจาก SharedPreferences
class LoadProducts extends ProductEvent {}

// เพิ่มสินค้าใหม่
class AddProduct extends ProductEvent {
  final String name;
  final double price;

  const AddProduct({required this.name, required this.price});

  @override
  List<Object?> get props => [name, price];
}

class UpdateProduct extends ProductEvent {
  final Product product;

  const UpdateProduct(this.product);

  @override
  List<Object?> get props => [product];
}
