import 'package:flutter/material.dart';

import '../../domain/constants/map_alert_enums.dart';
import '../../domain/entities/map_alert_entity.dart';
import '../../domain/entities/map_alert_extensions.dart';
import 'map_alert_styles.dart';

/// Pin liviano para zoom alejado (menos costo de pintura que el pin completo).
class CompactAlertDot extends StatelessWidget {
  const CompactAlertDot({
    super.key,
    required this.alert,
    required this.onTap,
  });

  final AlertEntity alert;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = MapAlertLevelStyle.forLevel(alert.level).pinAccent;
    final dimmed = !alert.isActiveAlert;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: dimmed ? 0.5 : 1,
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Burbuja de cluster con conteo de alertas.
class MapClusterBubble extends StatelessWidget {
  const MapClusterBubble({
    super.key,
    required this.count,
    required this.level,
    required this.onTap,
  });

  final int count;
  final AlertLevel level;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = MapAlertLevelStyle.forLevel(level).pinAccent;
    final size = count >= 100 ? 46.0 : count >= 10 ? 40.0 : 34.0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          count > 99 ? '99+' : '$count',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
