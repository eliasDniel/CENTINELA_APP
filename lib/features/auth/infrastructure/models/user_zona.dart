class UserZonaResponse {
  final String usuarioId;
  final String zonaId;
  final String tipo;
  final String createdAt;
  final ZonaResponse zona;

  UserZonaResponse({
    required this.usuarioId,
    required this.zonaId,
    required this.tipo,
    required this.createdAt,
    required this.zona,
  });

  factory UserZonaResponse.fromJson(Map<String, dynamic> json) =>
      UserZonaResponse(
        usuarioId: json["usuarioId"],
        zonaId: json["zonaId"],
        tipo: json["tipo"],
        createdAt: json["createdAt"],
        zona: ZonaResponse.fromJson(json["zona"]),
      );

  Map<String, dynamic> toJson() => {
    "usuarioId": usuarioId,
    "zonaId": zonaId,
    "tipo": tipo,
    "createdAt": createdAt,
    "zona": zona.toJson(),
  };
}

class ZonaResponse {
  final String id;
  final String nombre;
  final int riesgoNivel;

  ZonaResponse({
    required this.id,
    required this.nombre,
    required this.riesgoNivel,
  });

  factory ZonaResponse.fromJson(Map<String, dynamic> json) => ZonaResponse(
    id: json["id"],
    nombre: json["nombre"],
    riesgoNivel: json["riesgoNivel"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nombre": nombre,
    "riesgoNivel": riesgoNivel,
  };
}
