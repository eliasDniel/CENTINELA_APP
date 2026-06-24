class ZonasByUserResponse {
  final String zonaId;
  final String tipo;
  final String createdAt;
  final Zona zona;

  ZonasByUserResponse({
    required this.zonaId,
    required this.tipo,
    required this.createdAt,
    required this.zona,
  });

  factory ZonasByUserResponse.fromJson(Map<String, dynamic> json) =>
      ZonasByUserResponse(
        zonaId: json["zonaId"],
        tipo: json["tipo"],
        createdAt: json["createdAt"],
        zona: Zona.fromJson(json["zona"]),
      );

  Map<String, dynamic> toJson() => {
    "zonaId": zonaId,
    "tipo": tipo,
    "createdAt": createdAt,
    "zona": zona.toJson(),
  };
}

class Zona {
  final String id;
  final String nombre;
  final int riesgoNivel;
  final String? geomWkt;

  Zona({
    required this.id,
    required this.nombre,
    required this.riesgoNivel,
    this.geomWkt,
  });

  factory Zona.fromJson(Map<String, dynamic> json) => Zona(
    id: json["id"],
    nombre: json["nombre"],
    riesgoNivel: json["riesgoNivel"],
    geomWkt: json["geomWkt"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nombre": nombre,
    "riesgoNivel": riesgoNivel,
    "geomWkt": geomWkt,
  };
}
