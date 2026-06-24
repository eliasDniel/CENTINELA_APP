class ReportsResponse {
  final String id;

  final String tipo;

  final String descripcion;

  final String? zonaId;

  final String zonaNombre;

  final String estado;

  final int prioridad;

  final String? fotosUrls;

  final String createdAt;

  final int timestamp;

  final String? updatedAt;

  final double? latitud;

  final double? longitud;

  ReportsResponse({
    required this.id,

    required this.tipo,

    required this.descripcion,

    this.zonaId,

    required this.zonaNombre,

    required this.estado,

    required this.prioridad,

    this.fotosUrls,

    required this.createdAt,

    required this.timestamp,

    this.updatedAt,

    this.latitud,

    this.longitud,
  });

  factory ReportsResponse.fromJson(Map<String, dynamic> json) =>
      ReportsResponse(
        id: json['id'],

        tipo: json['tipo'],

        descripcion: json['descripcion'],

        zonaId: json['zonaId'],

        zonaNombre: json['zonaNombre'],

        estado: json['estado'],

        prioridad: json['prioridad'],

        fotosUrls: json['fotosUrls'],

        createdAt: json['createdAt'],

        timestamp: json['timestamp'],
        updatedAt: json['updatedAt'],

        latitud: json['latitud'],

        longitud: json['longitud'],
      );
}
