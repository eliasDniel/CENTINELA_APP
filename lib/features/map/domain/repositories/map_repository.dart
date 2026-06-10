// RF-0306: contrato del repositorio del mapa
import '../entities/map_alert_entity.dart';

abstract class MapRepository {
  Future<List<MapAlertEntity>> getActiveAlerts();
  MapAlertEntity generateIncomingAlert();
  MapAlertEntity publishSosAlert({
    required double lat,
    required double lng,
    required String zona,
    required String barrio,
    String? pseudonym,
    DateTime? timestamp,
  });
}
