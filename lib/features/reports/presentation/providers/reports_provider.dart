import 'package:centinela_milagro/features/auth/infrastructure/errors/auth_errors.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../domain/entities/report_entity.dart';
import '../../domain/repositories/reports_repository.dart';
import 'reports_repository_provider.dart';

class ReportsState {
  final List<ReportEntity> reports;
  final bool isLoading;
  final String errorMessage;

  const ReportsState({
    this.reports = const [],
    this.isLoading = false,
    this.errorMessage = '',
  });

  ReportsState copyWith({
    List<ReportEntity>? reports,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ReportsState(
      reports: reports ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ReportsNotifier extends StateNotifier<ReportsState> {
  final ReportsRepository repository;

  ReportsNotifier({required this.repository}) : super(const ReportsState());

  Future<String?> loadHistory() async {
    state = state.copyWith(isLoading: true, errorMessage: '');
    try {
      final reports = await repository.getHistoryReports();
      state = state.copyWith(reports: reports, isLoading: false);
      return null;
    } on CustomError catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return e.message;
    } catch (e) {
      const message = 'No se pudo cargar el historial';
      state = state.copyWith(isLoading: false, errorMessage: message);
      return message;
    }
  }

  Future<String?> sendSosAlert({
    required double latitude,
    required double longitude,
    String description = 'Alerta SOS de emergencia',
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: '');
    try {
      final report = await repository.sosAlert(
        'panico',
        description,
        latitude,
        longitude,
      );
      state = state.copyWith(
        reports: [report, ...state.reports],
        isLoading: false,
      );
      return null;
    } on CustomError catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return e.message;
    } catch (e) {
      const message = 'No se pudo enviar la alerta SOS';
      state = state.copyWith(isLoading: false, errorMessage: message);
      return message;
    }
  }

  Future<String?> submitReport(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, errorMessage: '');
    try {
      final report = await repository.submitReport(data);
      state = state.copyWith(
        reports: [report, ...state.reports],
        isLoading: false,
      );
      return null;
    } on CustomError catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return e.message;
    } catch (e) {
      const message = 'No se pudo enviar el reporte';
      state = state.copyWith(isLoading: false, errorMessage: message);
      return message;
    }
  }
}

final reportsProvider = StateNotifierProvider<ReportsNotifier, ReportsState>((
  ref,
) {
  final repository = ref.watch(reportsRepositoryProvider);
  return ReportsNotifier(repository: repository);
});
