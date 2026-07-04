import 'package:centinela_milagro/features/reports/domain/entities/report_entity.dart';

abstract class ReportsDatasources {
  Future<ReportEntity> sosAlert(
    String type,
    String description,
    double latitude,
    double longitude,
  );

  Future<ReportEntity> submitReport(Map<String, dynamic> data);

  /// Sube una imagen a Cloudinary vía `POST /media/upload?tipo=reporte`.
  Future<String> uploadReportMedia({
    required String filePath,
    String? filename,
  });

  Future<List<ReportEntity>> getHistoryReports();

  Future<ReportEntity> getReportById(String id);
}