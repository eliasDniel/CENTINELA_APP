class AlertZonaEntity {
  final String id;
  final String nombre;
  final int riesgoNivel;
  final String? geomWkt;

  const AlertZonaEntity({
    this.id = '',
    required this.nombre,
    required this.riesgoNivel,
    this.geomWkt,
  });
}
