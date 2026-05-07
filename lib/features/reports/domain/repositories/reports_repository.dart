// RF-0303, RF-0304: Reports repository interface
import '../entities/report_entity.dart';

abstract class ReportsRepository {
  Future<List<ReportEntity>> getRecentReports();
  Future<ReportEntity> submitReport(
    String type,
    String description,
    double latitude,
    double longitude,
    String userId,
  );
  Future<List<ReportEntity>> getUserHistory(String userId);
}
