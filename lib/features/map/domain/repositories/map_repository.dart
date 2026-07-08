import '../entities/map_alert_entity.dart';
import '../entities/user_zona_entity.dart';

abstract class MapRepository {
  Future<List<AlertEntity>> getActiveAlerts();
  Future<List<AlertEntity>> getMapAlerts({int horas = 24});
  Future<List<AlertEntity>> getPublicMapAlerts({int horas = 24});
  Future<List<UserZonaEntity>> getZonasByUser(String userId);
  Future<AlertEntity> getAlertById(String alertId);
}
