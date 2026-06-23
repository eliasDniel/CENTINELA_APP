import 'package:centinela_milagro/core/utils/api_timestamp.dart';

class AlertsResponse {
  final String id;
  final String codigo;
  final String tipo;
  final String descripcion;
  final String? zonaId;
  final int severidad;
  final String estado;
  final String? eventoId;
  final String? reporteId;
  final String? generadaPor;
  final String? reconocidaPor;
  final String? reconocidaEn;
  final String? cerradaPor;
  final String? cerradaEn;
  final String notas;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final ZonaResponse? zona;
  final double? latitud;
  final double? longitud;
  final int timestamp;

  AlertsResponse({
    required this.id,
    required this.codigo,
    required this.tipo,
    required this.descripcion,
    required this.zonaId,
    required this.severidad,
    required this.estado,
    required this.eventoId,
    required this.reporteId,
    required this.generadaPor,
    required this.reconocidaPor,
    required this.reconocidaEn,
    required this.cerradaPor,
    required this.cerradaEn,
    required this.notas,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.zona,
    required this.latitud,
    required this.longitud,
    required this.timestamp,
  });

  factory AlertsResponse.fromJson(Map<String, dynamic> json) {
    final createdAt = json['createdAt']?.toString() ?? '';
    return AlertsResponse(
      id: json['id']?.toString() ?? '',
      codigo: json['codigo']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      zonaId: json['zonaId']?.toString(),
      severidad: (json['severidad'] as num?)?.toInt() ?? 1,
      estado: json['estado']?.toString() ?? 'activa',
      eventoId: json['eventoId']?.toString(),
      reporteId: json['reporteId']?.toString(),
      generadaPor: json['generadaPor']?.toString(),
      reconocidaPor: json['reconocidaPor']?.toString(),
      reconocidaEn: json['reconocidaEn']?.toString(),
      cerradaPor: json['cerradaPor']?.toString(),
      cerradaEn: json['cerradaEn']?.toString(),
      notas: json['notas']?.toString() ?? '',
      createdAt: createdAt,
      updatedAt: json['updatedAt']?.toString() ?? '',
      deletedAt: json['deletedAt']?.toString(),
      zona: json['zona'] == null
          ? null
          : ZonaResponse.fromJson(Map<String, dynamic>.from(json['zona'] as Map)),
      latitud: (json['latitud'] as num?)?.toDouble(),
      longitud: (json['longitud'] as num?)?.toDouble(),
      timestamp: parseApiTimestamp(
        json['timestamp'],
        fallbackMs: parseApiTimestamp(createdAt),
      ),
    );
  }
}

class ZonaResponse {
  final String nombre;
  final int riesgoNivel;

  ZonaResponse({
    required this.nombre,
    required this.riesgoNivel,
  });

  factory ZonaResponse.fromJson(Map<String, dynamic> json) => ZonaResponse(
    nombre: json['nombre']?.toString() ?? '',
    riesgoNivel: (json['riesgoNivel'] as num?)?.toInt() ?? 1,
  );
}
