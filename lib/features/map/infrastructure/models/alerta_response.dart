import 'package:centinela_milagro/features/map/infrastructure/models/zonas_by_user_response.dart';

class AlertsResponse {
  final String id;
  final String codigo;
  final String tipo;
  final String descripcion;
  final String? zonaId;
  final int severidad;
  final String estado;
  final String? eventoId;
  final String reporteId;
  final String? generadaPor;
  final String? reconocidaPor;
  final String? reconocidaEn;
  final String? cerradaPor;
  final String? cerradaEn;
  final String notas;
  final String createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final Zona? zona;
  final double latitud;
  final double longitud;
  final int timestamp;

  AlertsResponse({
    required this.id,
    required this.codigo,
    required this.tipo,
    required this.descripcion,
    this.zonaId,
    required this.severidad,
    required this.estado,
    this.eventoId,
    required this.reporteId,
    this.generadaPor,
    this.reconocidaPor,
    this.reconocidaEn,
    this.cerradaPor,
    this.cerradaEn,
    required this.notas,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
    required this.zona,
    required this.latitud,
    required this.longitud,
    required this.timestamp,
  });

  factory AlertsResponse.fromJson(Map<String, dynamic> json) => AlertsResponse(
    id: json["id"],
    codigo: json["codigo"],
    tipo: json["tipo"],
    descripcion: json["descripcion"],
    zonaId: json["zonaId"],
    severidad: json["severidad"],
    estado: json["estado"],
    eventoId: json["eventoId"],
    reporteId: json["reporteId"],
    generadaPor: json["generadaPor"],
    reconocidaPor: json["reconocidaPor"],
    reconocidaEn: json["reconocidaEn"],
    cerradaPor: json["cerradaPor"],
    cerradaEn: json["cerradaEn"],
    notas: json["notas"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    deletedAt: json["deletedAt"],
    zona: json["zona"] != null ? Zona.fromJson(json["zona"]) : null,
    latitud: json["latitud"]?.toDouble(),
    longitud: json["longitud"]?.toDouble(),
    timestamp: json["timestamp"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "codigo": codigo,
    "tipo": tipo,
    "descripcion": descripcion,
    "zonaId": zonaId,
    "severidad": severidad,
    "estado": estado,
    "eventoId": eventoId,
    "reporteId": reporteId,
    "generadaPor": generadaPor,
    "reconocidaPor": reconocidaPor,
    "reconocidaEn": reconocidaEn,
    "cerradaPor": cerradaPor,
    "cerradaEn": cerradaEn,
    "notas": notas,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "deletedAt": deletedAt,
    "zona": zona?.toJson(),
    "latitud": latitud,
    "longitud": longitud,
    "timestamp": timestamp,
  };
}


