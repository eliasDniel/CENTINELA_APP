import '../../domain/entities/alert_zona_entity.dart';
import '../../domain/entities/map_alert_entity.dart';
import '../../domain/entities/user_zona_entity.dart';
import '../models/alerta_response.dart';
import '../models/zonas_by_user_response.dart';

class MapAlertMapper {
  static AlertEntity fromAlertsResponse(AlertsResponse response) {
    final zonaNombre = response.zona?.nombre ?? response.zonaNombre;
    return AlertEntity(
      id: response.id,
      codigo: response.codigo,
      tipo: response.tipo,
      descripcion: response.descripcion ?? '',
      zonaId: response.zonaId,
      severidad: response.severidad,
      estado: response.estado,
      eventoId: response.eventoId,
      reporteId: response.reporteId,
      generadaPor: response.generadaPor,
      reconocidaPor: response.reconocidaPor,
      reconocidaEn: response.reconocidaEn,
      cerradaPor: response.cerradaPor,
      cerradaEn: response.cerradaEn,
      notas: response.notas ?? '',
      createdAt: response.createdAt,
      updatedAt: response.updatedAt,
      deletedAt: response.deletedAt,
      zona: zonaNombre != null
          ? AlertZonaEntity(
              id: response.zona?.id ?? response.zonaId ?? '',
              nombre: zonaNombre,
              riesgoNivel: response.zona?.riesgoNivel ?? 1,
              geomWkt: response.zona?.geomWkt,
            )
          : null,
      latitud: response.latitud,
      longitud: response.longitud,
      timestamp: response.timestamp,
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
