// RF-0308: Get user history use case
import '../entities/report_entity.dart';
import '../repositories/reports_repository.dart';

class GetUserHistoryUseCase {
  final ReportsRepository repository;

  GetUserHistoryUseCase(this.repository);

  Future<List<ReportEntity>> call(String userId) {
    return repository.getUserHistory(userId);
  }
}
