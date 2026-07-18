// RF-0306: detalle expandible de la alerta seleccionada
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/location/user_location_provider.dart';
import '../../../../core/utils/format_time_ago.dart';
import '../../../subscriptions/domain/barrio_membership.dart';
import '../../domain/constants/map_alert_enums.dart';
import '../../domain/entities/map_alert_entity.dart';
import '../../domain/entities/map_alert_extensions.dart';
import 'map_alert_styles.dart';

class AlertDetailSheet extends StatelessWidget {
  const AlertDetailSheet({
    super.key,
    required this.alert,
    required this.barrioCategory,
    this.distanceFromUser,
    this.position,
  });

  final AlertEntity alert;
  final BarrioMapCategory barrioCategory;
  final double? distanceFromUser;
  final LatLng? position;

  MapAlertLevelStyle _levelStyle(AlertLevel level) =>
      MapAlertLevelStyle.forLevel(level);

  String _sourceText(AlertSource source) {
    return switch (source) {
      AlertSource.sensor_audio => 'Sensor IoT',
      AlertSource.ciudadano => 'Reporte ciudadano',
    };
  }

  IconData _sourceIcon(AlertSource source) {
    return switch (source) {
      AlertSource.sensor_audio => Icons.sensors_rounded,
      AlertSource.ciudadano => Icons.person_outline_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final levelStyle = _levelStyle(alert.level);
    final headerIcon = alert.markerIcon;

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF12151C),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: levelStyle.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: levelStyle.accent.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Icon(headerIcon, color: levelStyle.accent, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.displayTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          alert.codigo,
                          style: const TextStyle(
                            color: Color(0xFF9AA5B1),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Badge(label: levelStyle.label, color: levelStyle.accent),
                  if (alert.displayEstado.isNotEmpty)
                    _Badge(
                      label: alert.displayEstado,
                      color: const Color(0xFF78909C),
                    ),
                  _Badge(
                    label: _sourceText(alert.source),
                    color: const Color(0xFF5C6BC0),
                  ),
                  _BarrioCategoryBadge(
                    category: barrioCategory,
                    barrio: alert.barrio,
                  ),
                ],
              ),
              if (alert.displayDescription.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(
                  alert.displayDescription,
                  style: const TextStyle(
                    color: Color(0xFFCFD8DC),
                    fontSize: 15,
                    height: 1.45,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F28),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.place_outlined,
                      label: 'Ubicación',
                      value: locationLabel(
                        zona: alert.zonaNombre,
                        barrio: alert.barrio,
                        category: barrioCategory,
                      ),
                    ),
                    if (distanceFromUser != null)
                      _InfoRow(
                        icon: Icons.straighten_rounded,
                        label: 'Distancia',
                        value: 'A ${formatDistanceMeters(distanceFromUser!)} de ti',
                        valueColor: const Color(0xFF90CAF9),
                      ),
                    _InfoRow(
                      icon: Icons.schedule_rounded,
                      label: 'Registrada',
                      value: formatTimeAgo(alert.timestampDate),
                    ),
                    _InfoRow(
                      icon: _sourceIcon(alert.source),
                      label: 'Fuente',
                      value: _sourceText(alert.source),
                    ),

                    _InfoRow(
                      icon: Icons.description_outlined,
                      label: 'Descripción',
                      value: alert.descripcion,
                      valueColor: const Color(0xFF78909C),
                      showDivider: false,
                    ),
                    if (position != null)
                      _InfoRow(
                        icon: Icons.gps_fixed_rounded,
                        label: 'Coordenadas',
                        value:
                            '${position!.latitude.toStringAsFixed(4)}, ${position!.longitude.toStringAsFixed(4)}',
                        valueColor: const Color(0xFF78909C),
                        showDivider: false,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor = Colors.white,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: const Color(0xFF90A4AE)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF78909C),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        color: valueColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, thickness: 1, color: Colors.white10),
      ],
    );
  }
}

class _BarrioCategoryBadge extends StatelessWidget {
  const _BarrioCategoryBadge({
    required this.category,
    required this.barrio,
  });

  final BarrioMapCategory category;
  final String barrio;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (category) {
      BarrioMapCategory.home => (
          const Color(0xFF81C784),
          Icons.home_outlined,
        ),
      BarrioMapCategory.subscribed => (
          barrioAccentSoft(barrio),
          Icons.bookmark_outline,
        ),
      BarrioMapCategory.other => (
          const Color(0xFF78909C),
          Icons.location_off_outlined,
        ),
    };

    return _Badge(
      label: barrioCategoryLabel(category, barrio),
      color: color,
      icon: icon,
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
