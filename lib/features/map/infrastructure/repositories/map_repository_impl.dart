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
}
