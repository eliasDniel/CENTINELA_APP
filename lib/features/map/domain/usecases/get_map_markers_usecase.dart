// RF-0306: Get map markers use case
import '../entities/map_marker_entity.dart';
import '../repositories/map_repository.dart';

class GetMapMarkersUseCase {
  final MapRepository repository;

  GetMapMarkersUseCase(this.repository);

  Future<List<MapMarkerEntity>> call() {
    return repository.getMapMarkers();
  }
}
