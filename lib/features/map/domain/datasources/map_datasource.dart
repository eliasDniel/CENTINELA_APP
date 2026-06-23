import 'package:centinela_milagro/features/map/domain/entities/map_alert_entity.dart';


abstract class MapDatasource {
  Future<List<AlertEntity>> getActiveAlerts();
}
