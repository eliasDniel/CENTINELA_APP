class ZonaCatalogResponse {
  final String id;
  final String nombre;
  final String? descripcion;
  final int riesgoNivel;

  const ZonaCatalogResponse({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.riesgoNivel,
  });

  factory ZonaCatalogResponse.fromJson(Map<String, dynamic> json) {
    return ZonaCatalogResponse(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString(),
      riesgoNivel: (json['riesgoNivel'] as num?)?.toInt() ?? 1,
    );
  }
}
