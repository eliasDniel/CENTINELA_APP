import 'package:centinela_milagro/features/map/domain/datasources/map_datasource.dart';

import '../../domain/entities/map_alert_entity.dart';
import '../../domain/repositories/map_repository.dart';

class MapRepositoryImpl implements MapRepository {
  final MapDatasource datasources;

  MapRepositoryImpl({required this.datasources});

  @override
  Future<List<AlertEntity>> getActiveAlerts() {
    return datasources.getActiveAlerts();
  }

  @override
  Future<Map<String, dynamic>> getAlertById(String alertId) {
    return datasources.getAlertById(alertId);
  }

  @override
  Future<List<Map<String, dynamic>>> getZonasByUser(
    String userId,
    String zonaId,
  ) {
    return datasources.getZonasByUser(userId, zonaId);
  }
}
