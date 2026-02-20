import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/sale_item.dart';

class StorageService {
  // key สำหรับเก็บข้อมูลใน SharedPreferences
  static const String _productsKey = 'products';
  static const String _cartKey = 'cart';
  static const String _saleReportKey = 'sale_report';

  // ==================== Products ====================

  Future<void> saveProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = products.map((p) => p.toJson()).toList();
    await prefs.setString(_productsKey, jsonEncode(jsonList));
  }

  Future<List<Product>> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_productsKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList
        .map((json) => Product.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ==================== Cart ====================

  Future<void> saveCart(List<SaleItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items.map((item) => item.toJson()).toList();
    await prefs.setString(_cartKey, jsonEncode(jsonList));
  }

  Future<List<SaleItem>> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cartKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList
        .map((json) => SaleItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }

  // ==================== Sale Report ====================

  Future<void> saveSaleReport(List<SaleItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items.map((item) => item.toJson()).toList();
    await prefs.setString(_saleReportKey, jsonEncode(jsonList));
  }

  Future<List<SaleItem>> loadSaleReport() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_saleReportKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList
        .map((json) => SaleItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}