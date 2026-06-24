class ReportEntity {
  final String id;

  final String tipo;

  final String descripcion;

  final String? zonaId;

  final String? zonaNombre;

  final String estado;

  final int prioridad;

  final List<String> evidenceUrls;

  final String createdAt;

  final int timestamp;

  final String? updatedAt;

  final double? latitud;

  final double? longitud;

  const ReportEntity({
    required this.id,

    required this.tipo,

    required this.descripcion,

    this.zonaId,

    this.zonaNombre,

    required this.estado,

    required this.prioridad,

    this.evidenceUrls = const [],

    required this.createdAt,

    required this.timestamp,

    this.updatedAt,

    this.latitud,

    this.longitud,
  });
}
