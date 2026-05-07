// RF-0303: Get recent reports use case
import '../entities/report_entity.dart';
import '../repositories/reports_repository.dart';

class GetRecentReportsUseCase {
  final ReportsRepository repository;

  GetRecentReportsUseCase(this.repository);

  Future<List<ReportEntity>> call() {
    return repository.getRecentReports();
  }
}
