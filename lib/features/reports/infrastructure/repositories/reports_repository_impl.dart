import 'package:centinela_milagro/features/reports/domain/entities/report_entity.dart';

import '../../domain/datasources/report_datasources.dart';
import '../../domain/repositories/reports_repository.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsDatasources datasources;

  ReportsRepositoryImpl({required this.datasources});

  @override
  Future<List<ReportEntity>> getHistoryReports() {
    return datasources.getHistoryReports();
  }

  @override
  Future<ReportEntity> sosAlert(String type, String description, double latitude, double longitude) {
    return datasources.sosAlert(type, description, latitude, longitude);
  }

  @override
  Future<ReportEntity> submitReport(Map<String, dynamic> data) {
    return datasources.submitReport(data);
  }

  @override
  Future<String> uploadReportMedia({
    required String filePath,
    String? filename,
  }) {
    return datasources.uploadReportMedia(
      filePath: filePath,
      filename: filename,
    );
  }

  @override
  Future<ReportEntity> getReportById(String id) {
    return datasources.getReportById(id);
  }
}