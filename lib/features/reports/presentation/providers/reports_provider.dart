// RF-0303, RF-0304, RF-0307, RF-0308: Reports Riverpod providers
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/report_entity.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../domain/usecases/get_recent_reports_usecase.dart';
import '../../domain/usecases/submit_report_usecase.dart';
import '../../domain/usecases/get_user_history_usecase.dart';
import '../../infrastructure/datasources/reports_local_datasource.dart';
import '../../infrastructure/repositories/reports_repository_impl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../subscriptions/presentation/providers/subscriptions_provider.dart';

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  final dataSource = ReportsLocalDataSource();
  return ReportsRepositoryImpl(dataSource);
});

final recentReportsProvider =
    FutureProvider<List<ReportEntity>>((ref) async {
  final repository = ref.watch(reportsRepositoryProvider);
  final usecase = GetRecentReportsUseCase(repository);
  return usecase();
});

final submitReportProvider = FutureProvider.autoDispose
    .family<ReportEntity, (String, String, double, double, String)>(
  (ref, params) async {
    final repository = ref.watch(reportsRepositoryProvider);
    final usecase = SubmitReportUseCase(repository);
    return usecase(params.$1, params.$2, params.$3, params.$4, params.$5);
  },
);

final userReportsProvider = FutureProvider.autoDispose
    .family<List<ReportEntity>, String>((ref, userId) async {
  final repository = ref.watch(reportsRepositoryProvider);
  final usecase = GetUserHistoryUseCase(repository);
  return usecase(userId);
});

// RF-0309: Reportes filtrados por barrio propio del usuario
final myBarrioReportsProvider = FutureProvider<List<ReportEntity>>((ref) async {
  final authState = ref.watch(authProvider);
  final allReports = await ref.watch(recentReportsProvider.future);
  
  if (authState.user == null) {
    return [];
  }
  
  return allReports.where((r) => r.barrio == authState.user!.barrio).toList();
});

// RF-0309: Reportes de barrios suscritos
final subscribedReportsProvider = FutureProvider<List<ReportEntity>>((ref) async {
  final subscribed = ref.watch(barriosSubscribedProvider);
  final allReports = await ref.watch(recentReportsProvider.future);
  
  return allReports.where((r) => subscribed.contains(r.barrio)).toList();
});

// RF-0309: Todos los reportes combinados ordenados por fecha
final allReportsProvider = FutureProvider<List<ReportEntity>>((ref) async {
  final myBarrio = await ref.watch(myBarrioReportsProvider.future);
  final subscribed = await ref.watch(subscribedReportsProvider.future);
  
  final combined = {...myBarrio, ...subscribed}.toList();
  combined.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  
  return combined;
});

