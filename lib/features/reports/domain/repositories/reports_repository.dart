import 'package:centinela_milagro/features/reports/domain/entities/report_entity.dart';

abstract class ReportsRepository {
  Future<ReportEntity> sosAlert(
    String type,
    String description,
    double latitude,
    double longitude,
  );

  Future<ReportEntity> submitReport(Map<String, dynamic> data);

  Future<String> uploadReportMedia({
    required String filePath,
    String? filename,
  });

  Future<List<ReportEntity>> getHistoryReports();

  Future<ReportEntity> getReportById(String id);
}
