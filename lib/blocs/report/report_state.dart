import 'package:equatable/equatable.dart';
import '../../models/sale_item.dart';

abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportLoaded extends ReportState {
  final List<SaleItem> items;

  const ReportLoaded(this.items);

  // ยอดรวมทั้งหมด
  double get totalAmount =>
      items.fold(0.0, (sum, item) => sum + (item.price * item.qty));

  // จำนวนสินค้าทั้งหมด
  int get totalItems => items.fold(0, (sum, item) => sum + item.qty);

  @override
  List<Object?> get props => [items];
}

// ยังไม่มีรายการขาย
class ReportEmpty extends ReportState {}

class ReportError extends ReportState {
  final String message;

  const ReportError(this.message);

  @override
  List<Object?> get props => [message];
}