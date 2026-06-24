import 'package:centinela_milagro/features/map/domain/entities/map_alert_entity.dart';


abstract class MapDatasource {
  Future<List<AlertEntity>> getActiveAlerts();
  Future<List<Map<String, dynamic>>> getZonasByUser(String userId, String zonaId);
  Future<Map<String, dynamic>> getAlertById(String alertId);
}
