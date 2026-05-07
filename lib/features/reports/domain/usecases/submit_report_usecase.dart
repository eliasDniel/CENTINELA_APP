// RF-0303: Submit report use case
import '../entities/report_entity.dart';
import '../repositories/reports_repository.dart';

class SubmitReportUseCase {
  final ReportsRepository repository;

  SubmitReportUseCase(this.repository);

  Future<ReportEntity> call(
    String type,
    String description,
    double latitude,
    double longitude,
    String userId,
  ) {
    if (type.isEmpty) throw Exception('El tipo es requerido');
    if (description.isEmpty) throw Exception('La descripción es requerida');
    return repository.submitReport(type, description, latitude, longitude, userId);
  }
}
