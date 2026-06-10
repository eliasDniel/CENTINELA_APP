// RF-0101, RF-0102, RF-0105, RF-0204, RF-0303, RF-0304: entidad principal del mapa
import 'package:latlong2/latlong.dart';

enum AlertType {
  disparo,
  explosion,
  grito,
  vidrio_roto,
  alarma_vehiculo,
  nivel_hidrico,
  reporte_ciudadano,
  sos,
}

enum AlertSource {
  sensor_audio,
  sensor_video,
  sensor_hidrico,
  ciudadano,
}

enum AlertLevel {
  vigilancia,
  alerta,
  emergencia,
}

class MapAlertEntity {
  final String id;
  final double lat;
  final double lng;
  final AlertType type;
  final AlertSource source;
  final AlertLevel level;
  final String zona;
  final String barrio;
  final String description;
  final DateTime timestamp;
  final bool isActive;
  final String? nodeId;
  final String? algorithm;
  final double? confidence;
  final double? waterLevelDelta;
  final String? pseudonym;

  const MapAlertEntity({
    required this.id,
    required this.lat,
    required this.lng,
    required this.type,
    required this.source,
    required this.level,
    required this.zona,
    required this.barrio,
    required this.description,
    required this.timestamp,
    required this.isActive,
    this.nodeId,
    this.algorithm,
    this.confidence,
    this.waterLevelDelta,
    this.pseudonym,
  });

  LatLng get position => LatLng(lat, lng);

  MapAlertEntity copyWith({
    String? id,
    double? lat,
    double? lng,
    AlertType? type,
    AlertSource? source,
    AlertLevel? level,
    String? zona,
    String? barrio,
    String? description,
    DateTime? timestamp,
    bool? isActive,
    String? nodeId,
    String? algorithm,
    double? confidence,
    double? waterLevelDelta,
    String? pseudonym,
  }) {
    return MapAlertEntity(
      id: id ?? this.id,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      type: type ?? this.type,
      source: source ?? this.source,
      level: level ?? this.level,
      zona: zona ?? this.zona,
      barrio: barrio ?? this.barrio,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      isActive: isActive ?? this.isActive,
      nodeId: nodeId ?? this.nodeId,
      algorithm: algorithm ?? this.algorithm,
      confidence: confidence ?? this.confidence,
      waterLevelDelta: waterLevelDelta ?? this.waterLevelDelta,
      pseudonym: pseudonym ?? this.pseudonym,
    );
  }
}