import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/sale_item.dart';
import '../../services/storage_service.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final StorageService storageService;

  CartBloc({required this.storageService}) : super(CartInitial()) {
    on<LoadCart>(_onLoadCart);
    on<AddToCart>(_onAddToCart);
    on<IncreaseQty>(_onIncreaseQty);
    on<DecreaseQty>(_onDecreaseQty);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<Checkout>(_onCheckout);
  }

  // ดึง list ปัจจุบัน
  List<SaleItem> get _currentItems =>
      state is CartLoaded ? (state as CartLoaded).items : [];

  Future<void> _onLoadCart(
    LoadCart event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    try {
      final items = await storageService.loadCart();
      emit(CartLoaded(items));
    } catch (e) {
      emit(CartError('โหลดตะกร้าไม่สำเร็จ: $e'));
    }
  }

  Future<void> _onAddToCart(
    AddToCart event,
    Emitter<CartState> emit,
  ) async {
    try {
      final items = List<SaleItem>.from(_currentItems);

      // เช็คว่ามีสินค้านี้ในตะกร้าแล้วหรือยัง
      final index = items.indexWhere(
        (item) => item.productId == event.product.id,
      );

      if (index >= 0) {
        // มีแล้ว → เพิ่ม qty +1
        items[index] = items[index].copyWith(qty: items[index].qty + 1);
      } else {
        // ยังไม่มี → เพิ่มใหม่
        items.add(SaleItem(
          productId: event.product.id,
          name: event.product.name,
          price: event.product.price,
          qty: 1,
        ));
      }

      await storageService.saveCart(items);
      emit(CartLoaded(items));
    } catch (e) {
      emit(CartError('เพิ่มสินค้าไม่สำเร็จ: $e'));
    }
  }

  Future<void> _onIncreaseQty(
    IncreaseQty event,
    Emitter<CartState> emit,
  ) async {
    try {
      final items = List<SaleItem>.from(_currentItems);
      final index = items.indexWhere(
        (item) => item.productId == event.productId,
      );

      if (index >= 0) {
        items[index] = items[index].copyWith(qty: items[index].qty + 1);
        await storageService.saveCart(items);
        emit(CartLoaded(items));
      }
    } catch (e) {
      emit(CartError('อัพเดทไม่สำเร็จ: $e'));
    }
  }

  Future<void> _onDecreaseQty(
    DecreaseQty event,
    Emitter<CartState> emit,
  ) async {
    try {
      final items = List<SaleItem>.from(_currentItems);
      final index = items.indexWhere(
        (item) => item.productId == event.productId,
      );

      if (index >= 0) {
        if (items[index].qty > 1) {
          // qty > 1 → ลด 1
          items[index] = items[index].copyWith(qty: items[index].qty - 1);
        } else {
          // qty = 1 → ลบออก
          items.removeAt(index);
        }
        await storageService.saveCart(items);
        emit(CartLoaded(items));
      }
    } catch (e) {
      emit(CartError('อัพเดทไม่สำเร็จ: $e'));
    }
  }

  Future<void> _onRemoveFromCart(
    RemoveFromCart event,
    Emitter<CartState> emit,
  ) async {
    if (state is CartCheckingOut) return;
    try {
      final items = List<SaleItem>.from(_currentItems);
      items.removeWhere((item) => item.productId == event.productId);
      await storageService.saveCart(items);
      emit(CartLoaded(items));
    } catch (e) {
      emit(CartError('ลบสินค้าไม่สำเร็จ: $e'));
    }
  }

  Future<void> _onCheckout(
    Checkout event,
    Emitter<CartState> emit,
  ) async {
    try {
      final items = List<SaleItem>.from(_currentItems);
      if (items.isEmpty) return;

      // จำลองประมวลผล 2 วินาที
      emit(CartCheckingOut());
      await Future.delayed(const Duration(seconds: 2));

      // บันทึกรายงานการขาย
      await storageService.saveSaleReport(items);

      // เคลียร์ตะกร้า
      await storageService.clearCart();

      emit(CartCheckoutSuccess());
    } catch (e) {
      emit(CartError('Checkout ไม่สำเร็จ: $e'));
    }
  }
}
