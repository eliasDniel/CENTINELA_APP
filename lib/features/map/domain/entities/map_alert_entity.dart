import 'alert_zona_entity.dart';

class AlertEntity {
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
  final AlertZonaEntity? zona;
  final double? latitud;
  final double? longitud;
  final int timestamp;

  const AlertEntity({
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

  AlertEntity copyWith({
    String? id,
    String? codigo,
    String? tipo,
    String? descripcion,
    String? zonaId,
    int? severidad,
    String? estado,
    String? eventoId,
    String? reporteId,
    String? generadaPor,
    String? reconocidaPor,
    String? reconocidaEn,
    String? cerradaPor,
    String? cerradaEn,
    String? notas,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
    AlertZonaEntity? zona,
    double? latitud,
    double? longitud,
    int? timestamp,
  }) {
    return AlertEntity(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      tipo: tipo ?? this.tipo,
      descripcion: descripcion ?? this.descripcion,
      zonaId: zonaId ?? this.zonaId,
      severidad: severidad ?? this.severidad,
      estado: estado ?? this.estado,
      eventoId: eventoId ?? this.eventoId,
      reporteId: reporteId ?? this.reporteId,
      generadaPor: generadaPor ?? this.generadaPor,
      reconocidaPor: reconocidaPor ?? this.reconocidaPor,
      reconocidaEn: reconocidaEn ?? this.reconocidaEn,
      cerradaPor: cerradaPor ?? this.cerradaPor,
      cerradaEn: cerradaEn ?? this.cerradaEn,
      notas: notas ?? this.notas,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      zona: zona ?? this.zona,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
