import 'package:centinela_milagro/features/reports/domain/entities/report_entity.dart';

import '../../domain/entities/alert_zona_entity.dart';
import '../../domain/entities/map_alert_entity.dart';
import '../models/alerta_response.dart';

class MapAlertMapper {
  const MapAlertMapper._();

  static AlertEntity fromAlertsResponse(AlertsResponse response) {
    return AlertEntity(
      id: response.id,
      codigo: response.codigo,
      tipo: response.tipo,
      descripcion: response.descripcion,
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
      notas: response.notas,
      createdAt: response.createdAt,
      updatedAt: response.updatedAt,
      deletedAt: response.deletedAt,
      zona: response.zona == null
          ? null
          : AlertZonaEntity(
              nombre: response.zona!.nombre,
              riesgoNivel: response.zona!.riesgoNivel,
            ),
      latitud: response.latitud,
      longitud: response.longitud,
      timestamp: response.timestamp,
    );
  }

  static AlertEntity fromReportEntity(ReportEntity report) {
    return AlertEntity(
      id: report.id,
      codigo: 'REP-${report.id.substring(0, 8)}',
      tipo: 'reporte_ciudadano',
      descripcion: report.descripcion,
      zonaId: report.zonaId,
      severidad: report.prioridad >= 4 ? 4 : 2,
      estado: report.estado,
      eventoId: null,
      reporteId: report.id,
      generadaPor: 'sistema',
      reconocidaPor: null,
      reconocidaEn: null,
      cerradaPor: null,
      cerradaEn: null,
      notas: '',
      createdAt: report.createdAt,
      updatedAt: report.createdAt,
      deletedAt: null,
      zona: report.zonaNombre == null
          ? null
          : AlertZonaEntity(
              nombre: report.zonaNombre!,
              riesgoNivel: 2,
            ),
      latitud: report.latitud,
      longitud: report.longitud,
      timestamp: report.timestamp,
    );
  }
}
