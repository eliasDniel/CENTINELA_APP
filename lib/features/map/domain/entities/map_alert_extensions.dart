import 'package:flutter/material.dart';
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

  bool get _isCitizenAlert =>
      reporteId != null || tipo == 'reporte_ciudadano';

  /// Título legible para UI (sin enums crudos del backend).
  String get displayTitle {
    if (_isCitizenAlert) {
      final reportType = citizenReportType;
      if (reportType != null) return incidentTypeLabel(reportType);
      return incidentTypeLabel(kPanicIncidentType);
    }

    return switch (alertType) {
      AlertType.disparo => 'Disparo',
      AlertType.grito => 'Grito',
      AlertType.sos => 'SOS',
      AlertType.reporte_ciudadano => 'Alerta de sensor',
    };
  }

  /// Descripción ciudadana sin prefijo técnico del backend.
  String get displayDescription {
    if (_isCitizenAlert) {
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

  AlertSource get source =>
      _isCitizenAlert ? AlertSource.ciudadano : AlertSource.sensor_audio;

  /// Tipo de incidente ciudadano extraído de la descripción (p. ej. ROBO, PANICO).
  String? get citizenReportType =>
      _extractCitizenReportType(descripcion) ?? _citizenTipoFromField(tipo);

  AlertType get alertType {
    if (_isCitizenAlert) {
      final reportType = citizenReportType?.toUpperCase();
      if (reportType == kPanicIncidentType) return AlertType.sos;
      return AlertType.reporte_ciudadano;
    }

    return _sensorAlertTypeFromDescription(descripcion);
  }

  bool get isSos => alertType == AlertType.sos;

  /// Icono del pin según el tipo real (reportes ciudadanos o sensores).
  IconData get markerIcon {
    final reportType = citizenReportType;
    if (_isCitizenAlert && reportType != null) {
      return incidentTypeIcon(reportType);
    }
    return iconForSensorAlertType(alertType);
  }

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

AlertType _sensorAlertTypeFromDescription(String text) {
  final subtipo = _extractSensorSubtipo(text);
  return switch (subtipo) {
    'disparo' => AlertType.disparo,
    'grito' => AlertType.grito,
    _ => AlertType.disparo,
  };
}

String? _extractSensorSubtipo(String text) {
  final fromPattern = RegExp(
    r'(?:Detección IA \(|Confirmación cruzada \(2 nodos\): )\s*(disparo|grito)\b',
    caseSensitive: false,
  ).firstMatch(text);
  if (fromPattern != null) {
    return fromPattern.group(1)?.toLowerCase();
  }

  final lower = text.toLowerCase();
  if (RegExp(r'\bgrito\b').hasMatch(lower)) return 'grito';
  if (RegExp(r'\bdisparo\b').hasMatch(lower)) return 'disparo';
  return null;
}

IconData iconForSensorAlertType(AlertType type) {
  return switch (type) {
    AlertType.disparo => Icons.volume_up_outlined,
    AlertType.grito => Icons.mic_none_rounded,
    AlertType.reporte_ciudadano => Icons.sensors_rounded,
    AlertType.sos => Icons.sos_outlined,
  };
}

String? _citizenTipoFromField(String tipo) {
  final normalized = tipo.trim().toUpperCase();
  if (!isKnownIncidentType(normalized)) return null;
  return normalized;
}

String? _extractCitizenReportType(String text) {
  final match = RegExp(
    r'Reporte de ciudadano:\s*([A-Z0-9_]+)',
    caseSensitive: false,
  ).firstMatch(text);
  final value = match?.group(1)?.toUpperCase();
  if (value == null || !isKnownIncidentType(value)) return null;
  return value;
}

String? _extractCitizenReportNote(String text) {
  final match = RegExp(
    r'Reporte de ciudadano:\s*[A-Z0-9_]+\s*-\s*(.+)$',
    caseSensitive: false,
    dotAll: true,
  ).firstMatch(text.trim());
  return match?.group(1)?.trim();
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
