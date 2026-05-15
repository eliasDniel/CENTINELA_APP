// RF-0306: contrato del repositorio del mapa
import '../entities/map_alert_entity.dart';

abstract class MapRepository {
  Future<List<MapAlertEntity>> getActiveAlerts();
  MapAlertEntity generateIncomingAlert();
}
