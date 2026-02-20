import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/storage_service.dart';
import 'report_event.dart';
import 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final StorageService storageService;

  ReportBloc({required this.storageService}) : super(ReportInitial()) {
    on<LoadReport>(_onLoadReport);
  }

  Future<void> _onLoadReport(
    LoadReport event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    try {
      final items = await storageService.loadSaleReport();

      if (items.isEmpty) {
        emit(ReportEmpty());
      } else {
        emit(ReportLoaded(items));
      }
    } catch (e) {
      emit(ReportError('โหลดรายงานไม่สำเร็จ: $e'));
    }
  }
}
