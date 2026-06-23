import '../entities/map_alert_entity.dart';

abstract class MapRepository {
  Future<List<AlertEntity>> getActiveAlerts();
}
