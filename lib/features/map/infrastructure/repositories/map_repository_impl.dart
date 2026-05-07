// RF-0306: Map repository implementation
import '../../domain/entities/map_marker_entity.dart';
import '../../domain/repositories/map_repository.dart';
import '../datasources/map_local_datasource.dart';

class MapRepositoryImpl implements MapRepository {
  final MapLocalDataSource localDataSource;

  MapRepositoryImpl(this.localDataSource);

  @override
  Future<List<MapMarkerEntity>> getMapMarkers() {
    return localDataSource.getMapMarkers();
  }
}
