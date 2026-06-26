import 'package:centinela_milagro/features/auth/domain/entities/zona_entity.dart';
import 'package:centinela_milagro/features/map/domain/entities/alert_zona_entity.dart';
import 'package:centinela_milagro/features/map/domain/entities/user_zona_entity.dart';
import 'package:centinela_milagro/features/map/infrastructure/models/zonas_by_user_response.dart';

import '../models/zona_catalog_response.dart';

class SuscripcionesMapper {
  static ZonaEntity fromCatalogResponse(ZonaCatalogResponse response) {
    return ZonaEntity(
      id: response.id,
      nombre: response.nombre,
      descripcion: response.descripcion ?? '',
      riesgoNivel: response.riesgoNivel,
    );
  }

  static UserZonaEntity fromUserZonaResponse(ZonasByUserResponse response) {
    return UserZonaEntity(
      zonaId: response.zonaId,
      tipo: response.tipo,
      zona: AlertZonaEntity(
        id: response.zona.id,
        nombre: response.zona.nombre,
        riesgoNivel: response.zona.riesgoNivel,
        geomWkt: response.zona.geomWkt,
      ),
    );
  }
}
