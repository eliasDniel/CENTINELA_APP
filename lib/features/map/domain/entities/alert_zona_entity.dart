class AlertZonaEntity {
  final String nombre;
  final int riesgoNivel;
  final String? geomWkt;

  const AlertZonaEntity({
    required this.nombre,
    required this.riesgoNivel,
     this.geomWkt,
  });
}
