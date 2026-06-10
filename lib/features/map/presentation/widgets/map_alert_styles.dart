// Estilos suaves y consistentes para alertas en el mapa
import 'package:flutter/material.dart';

import '../../domain/entities/map_alert_entity.dart';
import '../../../subscriptions/domain/barrio_membership.dart';

class MapAlertLevelStyle {
  const MapAlertLevelStyle({
    required this.accent,
    required this.surface,
    required this.label,
  });

  final Color accent;
  final Color surface;
  final String label;

  static MapAlertLevelStyle forLevel(AlertLevel level) {
    return switch (level) {
      AlertLevel.emergencia => const MapAlertLevelStyle(
          accent: Color(0xFFCE8A8A),
          surface: Color(0xFF3D2C2C),
          label: 'Emergencia',
        ),
      AlertLevel.alerta => const MapAlertLevelStyle(
          accent: Color(0xFFD4A574),
          surface: Color(0xFF3A3428),
          label: 'Alerta',
        ),
      AlertLevel.vigilancia => const MapAlertLevelStyle(
          accent: Color(0xFF8BA4C7),
          surface: Color(0xFF2A3140),
          label: 'Vigilancia',
        ),
    };
  }
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
