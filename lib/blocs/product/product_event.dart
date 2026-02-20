import 'package:equatable/equatable.dart';

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
