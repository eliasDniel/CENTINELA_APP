// Estilos suaves y consistentes para alertas en el mapa
import 'package:flutter/material.dart';

import '../../domain/constants/map_alert_enums.dart';
import '../../../subscriptions/domain/barrio_membership.dart';

class MapAlertLevelStyle {
  const MapAlertLevelStyle({
    required this.accent,
    required this.surface,
    required this.label,
    required this.pinAccent,
  });

  final Color accent;
  final Color surface;
  final String label;
  /// Color del pin y texto del marcador (estilo Google Maps).
  final Color pinAccent;

  static MapAlertLevelStyle forLevel(AlertLevel level) {
    return switch (level) {
      AlertLevel.critico => const MapAlertLevelStyle(
          accent: Color(0xFFE57373),
          surface: Color(0xFF3D2C2C),
          label: 'Crítico',
          pinAccent: Color(0xFFD93025),
        ),
      AlertLevel.urgente => const MapAlertLevelStyle(
          accent: Color(0xFFFFB74D),
          surface: Color(0xFF3A3428),
          label: 'Urgente',
          pinAccent: Color(0xFFE37400),
        ),
      AlertLevel.preventivo => const MapAlertLevelStyle(
          accent: Color(0xFF81C784),
          surface: Color(0xFF243028),
          label: 'Preventivo',
          pinAccent: Color(0xFF1A73E8),
        ),
    };
  }
}

String levelShortLabel(AlertLevel level) {
  return MapAlertLevelStyle.forLevel(level).label;
}

String alertTypeLabel(AlertType type) {
  return switch (type) {
    AlertType.disparo => 'Disparo',
    AlertType.explosion => 'Explosión',
    AlertType.grito => 'Grito',
    AlertType.vidrio_roto => 'Vidrio roto',
    AlertType.alarma_vehiculo => 'Vehículo',
    AlertType.nivel_hidrico => 'Nivel hídrico',
    AlertType.reporte_ciudadano => 'Reporte',
    AlertType.sos => 'SOS',
  };
}

Color barrioAccentSoft(String barrio) {
  return switch (barrio) {
    'Chirijos' => const Color(0xFF9FA8DA),
    'Camilo Andrade' => const Color(0xFFF48FB1),
    'Ernesto Seminario' => const Color(0xFFFFCC80),
    'Coronel Enrique Valdez' => const Color(0xFFA5D6A7),
    'Paraíso de Chobo' => const Color(0xFF90CAF9),
    'Otros recintos' => const Color(0xFFB0BEC5),
    _ => const Color(0xFFB0BEC5),
  };
}

Color barrioBorderForCategory(BarrioMapCategory category, String barrio) {
  return switch (category) {
    BarrioMapCategory.home => const Color(0xFF81C784),
    BarrioMapCategory.subscribed => barrioAccentSoft(barrio),
    BarrioMapCategory.other => const Color(0xFF6B7280),
  };
}

IconData iconForAlertType(AlertType type) {
  return switch (type) {
    AlertType.disparo => Icons.volume_up_outlined,
    AlertType.explosion => Icons.local_fire_department_outlined,
    AlertType.grito => Icons.mic_none_rounded,
    AlertType.vidrio_roto => Icons.broken_image_outlined,
    AlertType.alarma_vehiculo => Icons.directions_car_outlined,
    AlertType.nivel_hidrico => Icons.water_drop_outlined,
    AlertType.reporte_ciudadano => Icons.person_outline,
    AlertType.sos => Icons.sos_outlined,
  };
}
