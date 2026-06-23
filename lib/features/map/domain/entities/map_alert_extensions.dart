import 'package:latlong2/latlong.dart';

import '../../../../core/utils/api_timestamp.dart';
import '../constants/map_alert_enums.dart';
import 'map_alert_entity.dart';

extension AlertEntityUi on AlertEntity {
  bool get hasPosition => latitud != null && longitud != null;

  LatLng? get position =>
      hasPosition ? LatLng(latitud!, longitud!) : null;

  LatLng positionAt(Map<String, LatLng> positions) {
    return positions[id] ?? position ?? const LatLng(-2.1344, -79.5874);
  }

  String get zonaNombre => zona?.nombre ?? '';

  String get barrio => '';

  String get description => descripcion;

  DateTime get timestampDate => apiTimestampToDateTime(timestamp);

  AlertLevel get level {
    if (severidad >= 4) return AlertLevel.emergencia;
    if (severidad >= 3) return AlertLevel.alerta;
    return AlertLevel.vigilancia;
  }

  AlertSource get source {
    final normalized = tipo.toLowerCase();
    if (normalized.contains('hidric') || normalized.contains('hidrol')) {
      return AlertSource.sensor_hidrico;
    }
    if (normalized == 'reporte_ciudadano' || reporteId != null) {
      return AlertSource.ciudadano;
    }
    if (normalized.contains('video')) return AlertSource.sensor_video;
    if (normalized.contains('audio') || eventoId != null) {
      return AlertSource.sensor_audio;
    }
    return AlertSource.sensor_audio;
  }

  AlertType get alertType {
    final text = '$tipo $descripcion'.toLowerCase();
    if (text.contains('panico') || text.contains('sos')) {
      return AlertType.sos;
    }
    if (tipo == 'reporte_ciudadano' || reporteId != null) {
      return AlertType.reporte_ciudadano;
    }
    if (text.contains('disparo')) return AlertType.disparo;
    if (text.contains('explosion')) return AlertType.explosion;
    if (text.contains('grito')) return AlertType.grito;
    if (text.contains('vidrio')) return AlertType.vidrio_roto;
    if (text.contains('vehiculo') || text.contains('alarma')) {
      return AlertType.alarma_vehiculo;
    }
    if (text.contains('hidric') || text.contains('hidrol')) {
      return AlertType.nivel_hidrico;
    }
    return AlertType.reporte_ciudadano;
  }

  bool get isSos => alertType == AlertType.sos;
}

Map<String, LatLng> positionsFromAlerts(List<AlertEntity> alerts) {
  final positions = <String, LatLng>{};
  for (final alert in alerts) {
    final point = alert.position;
    if (point != null) {
      positions[alert.id] = point;
    }
  }
  return positions;
}
