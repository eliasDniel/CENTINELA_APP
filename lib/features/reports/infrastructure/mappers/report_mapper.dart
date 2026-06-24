
import 'package:centinela_milagro/features/reports/infrastructure/models/reports_response.dart';

import '../../domain/entities/report_entity.dart';

class ReportMapper {
  static ReportEntity fromReportsResponse(ReportsResponse response) {
    return ReportEntity(
      id: response.id,
      tipo: response.tipo,
      descripcion: response.descripcion,
      zonaId: response.zonaId,
      zonaNombre: response.zonaNombre,
      estado: response.estado,
      prioridad: response.prioridad,
      fotosUrls: response.fotosUrls,
      createdAt: response.createdAt,
      timestamp: response.timestamp,
      updatedAt: response.updatedAt,
      latitud: response.latitud,
      longitud: response.longitud,
    );
  }


}
