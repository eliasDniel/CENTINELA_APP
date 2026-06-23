// RF-0306 + RF-0309: marcador tipo pin, colores suaves
import 'package:flutter/material.dart';

import '../../../subscriptions/domain/barrio_membership.dart';
import '../../domain/constants/map_alert_enums.dart';
import '../../domain/entities/map_alert_entity.dart';
import '../../domain/entities/map_alert_extensions.dart';
import 'map_alert_styles.dart';

class AlertMarkerWidget extends StatelessWidget {
  const AlertMarkerWidget({
    super.key,
    required this.alert,
    required this.barrioCategory,
    required this.onTap,
  });

  final AlertEntity alert;
  final BarrioMapCategory barrioCategory;
  final VoidCallback onTap;

  static const _pinSize = 40.0;

  String? get _caption => switch (barrioCategory) {
        BarrioMapCategory.home => 'Tú',
        BarrioMapCategory.subscribed => alert.barrio,
        BarrioMapCategory.other => null,
      };

  @override
  Widget build(BuildContext context) {
    final level = MapAlertLevelStyle.forLevel(alert.level);
    final barrioBorder = barrioBorderForCategory(barrioCategory, alert.barrio);
    final dimmed = barrioCategory == BarrioMapCategory.other;
    final caption = _caption;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: dimmed ? 0.5 : 1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PinHead(
              level: level,
              barrioBorder: barrioBorder,
              icon: iconForAlertType(alert.alertType),
              pulse: alert.level == AlertLevel.emergencia && !dimmed,
            ),
            CustomPaint(
              size: const Size(12, 7),
              painter: _PinTailPainter(color: level.surface),
            ),
            if (caption != null) ...[
              const SizedBox(height: 2),
              _CaptionPill(text: caption, accent: barrioBorder),
            ],
          ],
        ),
      ),
    );
  }
}

class _PinHead extends StatelessWidget {
  const _PinHead({
    required this.level,
    required this.barrioBorder,
    required this.icon,
    required this.pulse,
  });

  final MapAlertLevelStyle level;
  final Color barrioBorder;
  final IconData icon;
  final bool pulse;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AlertMarkerWidget._pinSize,
      height: AlertMarkerWidget._pinSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (pulse)
            Container(
              width: AlertMarkerWidget._pinSize + 6,
              height: AlertMarkerWidget._pinSize + 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: level.accent.withOpacity(0.12),
              ),
            ),
          Container(
            width: AlertMarkerWidget._pinSize,
            height: AlertMarkerWidget._pinSize,
            decoration: BoxDecoration(
              color: level.surface,
              shape: BoxShape.circle,
              border: Border.all(color: barrioBorder.withOpacity(0.85), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(icon, size: 18, color: level.accent),
                ),
                Positioned(
                  top: 3,
                  right: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: level.accent.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: level.accent.withOpacity(0.5),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      level.label[0],
                      style: TextStyle(
                        color: level.accent,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CaptionPill extends StatelessWidget {
  const _CaptionPill({required this.text, required this.accent});

  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xE61C1C2E),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: accent.withOpacity(0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: accent.withOpacity(0.95),
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PinTailPainter extends CustomPainter {
  _PinTailPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _PinTailPainter oldDelegate) =>
      oldDelegate.color != color;
}
