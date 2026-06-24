import 'package:latlong2/latlong.dart';

import '../../../../core/utils/api_timestamp.dart';
import '../../../reports/domain/constants/incident_types.dart';
import '../constants/map_alert_enums.dart';
import 'map_alert_entity.dart';
import 'user_zona_entity.dart';

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

  DateTime get timestampDate {
    if (timestamp > 0) {
      return apiTimestampToDateTime(timestamp);
    }
    final parsed = DateTime.tryParse(createdAt);
    if (parsed != null) return parsed.toLocal();
    return DateTime.now();
  }

  /// Título legible para UI (sin enums crudos del backend).
  String get displayTitle {
    if (source == AlertSource.ciudadano || reporteId != null) {
      final reportType = _extractCitizenReportType(descripcion);
      if (reportType != null) return incidentTypeLabel(reportType);
    }
    if (tipo.isNotEmpty && tipo != 'reporte_ciudadano') {
      final fromTipo = incidentTypeLabel(tipo);
      if (fromTipo != tipo.replaceAll('_', ' ')) return fromTipo;
    }
    return _alertTypeDisplayLabel(alertType);
  }

  /// Descripción ciudadana sin prefijo técnico del backend.
  String get displayDescription {
    if (source == AlertSource.ciudadano || reporteId != null) {
      final note = _extractCitizenReportNote(descripcion);
      if (note != null &&
          note.isNotEmpty &&
          note.toLowerCase() != 'sin descripción') {
        return note;
      }
      return '';
    }
    final text = descripcion.trim();
    if (text.isEmpty) return '';
    final upperTipo = tipo.toUpperCase();
    if (text.toUpperCase() == upperTipo) return '';
    if (text.startsWith('Reporte de ciudadano:')) {
      return _extractCitizenReportNote(text) ?? '';
    }
    return text;
  }

  String get displayEstado {
    if (estado.isEmpty) return '';
    return estado[0].toUpperCase() + estado.substring(1).replaceAll('_', ' ');
  }

  AlertLevel get level {
    if (severidad >= 4) return AlertLevel.critico;
    if (severidad >= 3) return AlertLevel.urgente;
    return AlertLevel.preventivo;
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

  bool belongsToUserZone(List<UserZonaEntity> userZonas) {
    if (userZonas.isEmpty) return true;
    final alertZonaId = zonaId ?? zona?.id;
    if (alertZonaId != null && alertZonaId.isNotEmpty) {
      return userZonas.any((zone) => zone.zonaId == alertZonaId);
    }
    if (zonaNombre.isEmpty) return false;
    return userZonas.any((zone) => zone.zona.nombre == zonaNombre);
  }
}

String? _extractCitizenReportType(String text) {
  final match = RegExp(
    r'Reporte de ciudadano:\s*([A-Z0-9_]+)',
    caseSensitive: false,
  ).firstMatch(text);
  return match?.group(1)?.toUpperCase();
}

String? _extractCitizenReportNote(String text) {
  final match = RegExp(
    r'Reporte de ciudadano:\s*[A-Z0-9_]+\s*-\s*(.+)$',
    caseSensitive: false,
    dotAll: true,
  ).firstMatch(text.trim());
  return match?.group(1)?.trim();
}

String _alertTypeDisplayLabel(AlertType type) {
  return switch (type) {
    AlertType.disparo => 'Disparo',
    AlertType.explosion => 'Explosión',
    AlertType.grito => 'Grito',
    AlertType.vidrio_roto => 'Vidrio roto',
    AlertType.alarma_vehiculo => 'Alarma de vehículo',
    AlertType.nivel_hidrico => 'Nivel hídrico',
    AlertType.reporte_ciudadano => 'Reporte ciudadano',
    AlertType.sos => 'SOS',
  };
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
