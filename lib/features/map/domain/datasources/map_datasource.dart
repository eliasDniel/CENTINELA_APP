import 'package:centinela_milagro/features/map/domain/entities/map_alert_entity.dart';

import '../entities/user_zona_entity.dart';

abstract class MapDatasource {
  Future<List<AlertEntity>> getActiveAlerts();
  Future<List<UserZonaEntity>> getZonasByUser(String userId);
  Future<AlertEntity> getAlertById(String alertId);
}
