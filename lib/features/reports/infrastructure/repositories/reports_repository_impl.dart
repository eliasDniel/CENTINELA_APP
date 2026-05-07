// RF-0303, RF-0304: Reports repository implementation
import '../../domain/entities/report_entity.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_local_datasource.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsLocalDataSource localDataSource;

  ReportsRepositoryImpl(this.localDataSource);

  @override
  Future<List<ReportEntity>> getRecentReports() async {
    final models = await localDataSource.getRecentReports();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ReportEntity> submitReport(
    String type,
    String description,
    double latitude,
    double longitude,
    String userId,
  ) async {
    final model = await localDataSource.submitReport(
      type,
      description,
      latitude,
      longitude,
      userId,
    );
    return model.toEntity();
  }

  @override
  Future<List<ReportEntity>> getUserHistory(String userId) async {
    final models = await localDataSource.getUserHistory(userId);
    return models.map((m) => m.toEntity()).toList();
  }
}
