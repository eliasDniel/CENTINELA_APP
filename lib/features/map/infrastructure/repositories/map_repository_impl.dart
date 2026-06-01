// RF-0306: implementación del repositorio del mapa
import '../../domain/entities/map_alert_entity.dart';
import '../../domain/repositories/map_repository.dart';
import '../datasources/map_local_datasource.dart';

class MapRepositoryImpl implements MapRepository {
  final MapLocalDataSource localDataSource;

  MapRepositoryImpl(this.localDataSource);

  @override
  Future<List<MapAlertEntity>> getActiveAlerts() {
    return localDataSource.getActiveAlerts();
  }

  @override
  MapAlertEntity generateIncomingAlert() {
    return localDataSource.createIncomingAlert();
  }

  @override
  MapAlertEntity publishSosAlert({
    required double lat,
    required double lng,
    required String barrio,
    String? pseudonym,
    DateTime? timestamp,
  }) {
    return localDataSource.addSosAlert(
      lat: lat,
      lng: lng,
      barrio: barrio,
      pseudonym: pseudonym,
      timestamp: timestamp,
    );
  }
}
