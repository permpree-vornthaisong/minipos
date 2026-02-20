import 'package:equatable/equatable.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

// โหลดรายงานการขายครั้งล่าสุด
class LoadReport extends ReportEvent {}