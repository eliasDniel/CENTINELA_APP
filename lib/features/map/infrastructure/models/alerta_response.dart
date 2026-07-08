import 'package:centinela_milagro/core/utils/api_timestamp.dart';
import 'package:centinela_milagro/features/map/infrastructure/models/zonas_by_user_response.dart';

class AlertsResponse {
  final String id;
  final String codigo;
  final String tipo;
  final String? descripcion;
  final String? zonaId;
  final String? zonaNombre;
  final int severidad;
  final String estado;
  final String? eventoId;
  final String? reporteId;
  final String? generadaPor;
  final String? reconocidaPor;
  final String? reconocidaEn;
  final String? cerradaPor;
  final String? cerradaEn;
  final String? notas;
  final String createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final Zona? zona;
  final double? latitud;
  final double? longitud;
  final int timestamp;

  AlertsResponse({
    required this.id,
    required this.codigo,
    required this.tipo,
    this.descripcion,
    this.zonaId,
    this.zonaNombre,
    required this.severidad,
    required this.estado,
    this.eventoId,
    this.reporteId,
    this.generadaPor,
    this.reconocidaPor,
    this.reconocidaEn,
    this.cerradaPor,
    this.cerradaEn,
    this.notas,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.zona,
    this.latitud,
    this.longitud,
    required this.timestamp,
  });

  factory AlertsResponse.fromJson(Map<String, dynamic> json) => AlertsResponse(
    id: json["id"]?.toString() ?? '',
    codigo: json["codigo"]?.toString() ?? '',
    tipo: json["tipo"]?.toString() ?? '',
    descripcion: json["descripcion"]?.toString(),
    zonaId: json["zonaId"]?.toString(),
    zonaNombre: json["zonaNombre"]?.toString(),
    severidad: (json["severidad"] as num?)?.toInt() ?? 1,
    estado: json["estado"]?.toString() ?? '',
    eventoId: json["eventoId"]?.toString(),
    reporteId: json["reporteId"]?.toString(),
    generadaPor: json["generadaPor"]?.toString(),
    reconocidaPor: json["reconocidaPor"]?.toString(),
    reconocidaEn: json["reconocidaEn"]?.toString(),
    cerradaPor: json["cerradaPor"]?.toString(),
    cerradaEn: json["cerradaEn"]?.toString(),
    notas: json["notas"]?.toString(),
    createdAt: json["createdAt"]?.toString() ?? '',
    updatedAt: json["updatedAt"]?.toString(),
    deletedAt: json["deletedAt"]?.toString(),
    zona: json["zona"] != null
        ? Zona.fromJson({
            ...(json["zona"] as Map<String, dynamic>),
            "id": (json["zona"] as Map<String, dynamic>)["id"] ??
                json["zonaId"] ??
                '',
            "riesgoNivel":
                (json["zona"] as Map<String, dynamic>)["riesgoNivel"] ?? 1,
          })
        : null,
    latitud: (json["latitud"] as num?)?.toDouble(),
    longitud: (json["longitud"] as num?)?.toDouble(),
    timestamp: parseApiTimestamp(
      json['timestamp'],
      fallbackMs: DateTime.tryParse(json['createdAt']?.toString() ?? '')
          ?.millisecondsSinceEpoch,
    ),
  );
}
