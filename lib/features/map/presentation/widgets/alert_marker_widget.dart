// RF-0306: marcador de alerta con pulso para emergencias
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../domain/entities/map_alert_entity.dart';

class AlertMarkerWidget extends StatelessWidget {
  final MapAlertEntity alert;
  final VoidCallback onTap;

  const AlertMarkerWidget({
    super.key,
    required this.alert,
    required this.onTap,
  });

  Color _levelColor(AlertLevel level) {
    switch (level) {
      case AlertLevel.emergencia:
        return const Color(0xFFFF3B30);
      case AlertLevel.alerta:
        return const Color(0xFFFF9500);
      case AlertLevel.vigilancia:
        return const Color(0xFF1E90FF);
    }
  }

  IconData _iconForType(AlertType type) {
    switch (type) {
      case AlertType.disparo:
        return Icons.gpp_bad_rounded;
      case AlertType.explosion:
        return Icons.local_fire_department_rounded;
      case AlertType.grito:
        return Icons.record_voice_over_rounded;
      case AlertType.vidrio_roto:
        return Icons.broken_image_rounded;
      case AlertType.alarma_vehiculo:
        return Icons.directions_car_rounded;
      case AlertType.nivel_hidrico:
        return Icons.water_rounded;
      case AlertType.reporte_ciudadano:
        return Icons.report_rounded;
      case AlertType.sos:
        return Icons.emergency_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _levelColor(alert.level);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        height: 64,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (alert.level == AlertLevel.emergencia)
              Animate(
                onPlay: (controller) => controller.repeat(),
                effects: [
                  ScaleEffect(
                    begin: const Offset(1, 1),
                    end: const Offset(1.6, 1.6),
                    duration: 1200.ms,
                    curve: Curves.easeOut,
                  ),
                  FadeEffect(
                    begin: 0.7,
                    end: 0.0,
                    duration: 1200.ms,
                  ),
                ],
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.20),
                  ),
                ),
              ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.90),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.45),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                _iconForType(alert.type),
                color: Colors.white,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}