// RF-0306: caso de uso para obtener alertas activas
import '../entities/map_alert_entity.dart';
import '../repositories/map_repository.dart';

class GetActiveAlertsUseCase {
  final MapRepository repository;

  GetActiveAlertsUseCase(this.repository);

  Future<List<MapAlertEntity>> call() {
    return repository.getActiveAlerts();
  }
}