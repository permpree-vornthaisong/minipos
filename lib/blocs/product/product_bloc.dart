import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../models/product.dart';
import '../../services/storage_service.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final StorageService storageService;
  final _uuid = const Uuid();

  ProductBloc({required this.storageService}) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<AddProduct>(_onAddProduct);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      final products = await storageService.loadProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError('โหลดสินค้าไม่สำเร็จ: $e'));
    }
  }

  Future<void> _onAddProduct(
    AddProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      // ดึง list ปัจจุบัน
      final currentProducts = state is ProductLoaded
          ? (state as ProductLoaded).products
          : <Product>[];

      // สร้างสินค้าใหม่
      final newProduct = Product(
        id: _uuid.v4(),
        name: event.name,
        price: event.price,
      );

      // เพิ่มเข้า list แล้ว save
      final updatedProducts = [...currentProducts, newProduct];
      await storageService.saveProducts(updatedProducts);

      emit(ProductLoaded(updatedProducts));
    } catch (e) {
      emit(ProductError('เพิ่มสินค้าไม่สำเร็จ: $e'));
    }
  }
}
