// RF-0306: Map marker entity
class MapMarkerEntity {
  final String id;
  final double latitude;
  final double longitude;
  final String type; // 'emergencia', 'alerta', 'incidente_menor'
  final String label;
  final String description;

  MapMarkerEntity({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.label,
    required this.description,
  });
}
