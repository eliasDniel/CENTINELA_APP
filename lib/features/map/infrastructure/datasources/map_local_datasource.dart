// RF-0306: Map marker local datasource with mock data
import '../../domain/entities/map_marker_entity.dart';

class MapLocalDataSource {
  Future<List<MapMarkerEntity>> getMapMarkers() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      MapMarkerEntity(
        id: '1',
        latitude: -2.1234,
        longitude: -79.5678,
        type: 'emergencia',
        label: 'Asalto - Central y 5ta',
        description: 'Reporte de asalto en la zona residencial',
      ),
      MapMarkerEntity(
        id: '2',
        latitude: -2.1250,
        longitude: -79.5690,
        type: 'emergencia',
        label: 'Choque - Avenida Principal',
        description: 'Accidente vial reportado',
      ),
      MapMarkerEntity(
        id: '3',
        latitude: -2.1200,
        longitude: -79.5650,
        type: 'alerta',
        label: 'Persona sospechosa - Parque',
        description: 'Individuo merodeando',
      ),
      MapMarkerEntity(
        id: '4',
        latitude: -2.1280,
        longitude: -79.5710,
        type: 'alerta',
        label: 'Hueco en calle - Calle 3ra',
        description: 'Daño vial peligroso',
      ),
      MapMarkerEntity(
        id: '5',
        latitude: -2.1220,
        longitude: -79.5680,
        type: 'incidente_menor',
        label: 'Conflicto vecinal - Zona Centro',
        description: 'Disputa de menor gravedad',
      ),
    ];
  }
}
