import 'package:equatable/equatable.dart';
import '../../models/sale_item.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

// ตะกร้ามีสินค้า
class CartLoaded extends CartState {
  final List<SaleItem> items;

  const CartLoaded(this.items);

  // จำนวนสินค้าทั้งหมด (รวม qty)
  int get totalItems => items.fold(0, (sum, item) => sum + item.qty);

  // ยอดรวม
  double get totalAmount =>
      items.fold(0.0, (sum, item) => sum + (item.price * item.qty));

  @override
  List<Object?> get props => [items];
}

// กำลัง checkout (รอ 2 วิ)
class CartCheckingOut extends CartState {}

// checkout สำเร็จ
class CartCheckoutSuccess extends CartState {}

class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object?> get props => [message];
}
