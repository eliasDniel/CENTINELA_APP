import '../entities/map_alert_entity.dart';

abstract class MapRepository {
    Future<List<AlertEntity>> getActiveAlerts();
  Future<List<Map<String, dynamic>>> getZonasByUser(String userId, String zonaId);
  Future<Map<String, dynamic>> getAlertById(String alertId);
}
