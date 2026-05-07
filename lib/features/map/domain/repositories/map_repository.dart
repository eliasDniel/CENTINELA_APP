// RF-0306: Map repository interface
import '../entities/map_marker_entity.dart';

abstract class MapRepository {
  Future<List<MapMarkerEntity>> getMapMarkers();
}
