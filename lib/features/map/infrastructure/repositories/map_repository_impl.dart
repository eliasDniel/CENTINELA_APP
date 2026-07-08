import 'package:centinela_milagro/features/map/domain/datasources/map_datasource.dart';

import '../../domain/entities/map_alert_entity.dart';
import '../../domain/entities/user_zona_entity.dart';
import '../../domain/repositories/map_repository.dart';

class MapRepositoryImpl implements MapRepository {
  final MapDatasource datasources;

  MapRepositoryImpl({required this.datasources});

  @override
  Future<List<AlertEntity>> getActiveAlerts() {
    return datasources.getActiveAlerts();
  }

  @override
  Future<List<AlertEntity>> getMapAlerts({int horas = 24}) {
    return datasources.getMapAlerts(horas: horas);
  }

  @override
  Future<List<AlertEntity>> getPublicMapAlerts({int horas = 24}) {
    return datasources.getPublicMapAlerts(horas: horas);
  }

  @override
  Future<AlertEntity> getAlertById(String alertId) {
    return datasources.getAlertById(alertId);
  }

  @override
  Future<List<UserZonaEntity>> getZonasByUser(String userId) {
    return datasources.getZonasByUser(userId);
  }
}
