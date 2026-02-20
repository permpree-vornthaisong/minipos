import 'package:equatable/equatable.dart';
import '../../models/product.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

// โหลดตะกร้าจาก SharedPreferences
class LoadCart extends CartEvent {}

// เพิ่มสินค้าเข้าตะกร้า (แตะจาก GridView)
class AddToCart extends CartEvent {
  final Product product;

  const AddToCart(this.product);

  @override
  List<Object?> get props => [product];
}

// เพิ่ม qty +1
class IncreaseQty extends CartEvent {
  final String productId;

  const IncreaseQty(this.productId);

  @override
  List<Object?> get props => [productId];
}

// ลด qty -1
class DecreaseQty extends CartEvent {
  final String productId;

  const DecreaseQty(this.productId);

  @override
  List<Object?> get props => [productId];
}

// ลบสินค้าออกจากตะกร้า
class RemoveFromCart extends CartEvent {
  final String productId;

  const RemoveFromCart(this.productId);

  @override
  List<Object?> get props => [productId];
}

// กด Checkout
class Checkout extends CartEvent {}
