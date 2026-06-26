// Marcador estilo Google Maps: etiqueta + pin tipo gota
import 'package:flutter/material.dart';

import '../../../subscriptions/domain/barrio_membership.dart';
import '../../domain/constants/map_alert_enums.dart';
import '../../domain/entities/map_alert_entity.dart';
import '../../domain/entities/map_alert_extensions.dart';
import 'map_alert_styles.dart';

/// Ancho del widget completo (debe coincidir con [Marker] en map_page).
const kAlertMarkerWidth = 168.0;

/// Pin anclado abajo a la derecha; la punta marca la coordenada exacta.
const kAlertPinWidth = 34.0;
const kAlertPinHeight = 44.0;

/// Alto del contenedor: espacio para etiqueta a la izquierda; el pin va abajo.
const kAlertMarkerHeight = 52.0;

/// Posición de la punta del pin dentro del widget (px desde arriba-izquierda).
double get kAlertPinTipLeft => kAlertMarkerWidth - kAlertPinWidth / 2;
double get kAlertPinTipTop => kAlertMarkerHeight;

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

  @override
  Widget build(BuildContext context) {
    final level = MapAlertLevelStyle.forLevel(alert.level);
    final dimmed = barrioCategory == BarrioMapCategory.other;
    final title = alert.displayTitle;
    final subtitle = _subtitleFor(alert, barrioCategory);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: dimmed ? 0.55 : 1,
        child: SizedBox(
          width: kAlertMarkerWidth,
          height: kAlertMarkerHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: 0,
                bottom: 0,
                child: _MapPin(
                  accent: level.pinAccent,
                  icon: alert.markerIcon,
                  showSosLabel: alert.isSos,
                  pulse: alert.level == AlertLevel.critico && !dimmed,
                ),
              ),
              Positioned(
                left: 0,
                right: kAlertPinWidth + 6,
                bottom: 8,
                child: _MarkerLabel(
                  title: title,
                  subtitle: subtitle,
                  accent: level.pinAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitleFor(AlertEntity alert, BarrioMapCategory category) {
    if (alert.zonaNombre.isNotEmpty) return alert.zonaNombre;
    return switch (category) {
      BarrioMapCategory.home => 'Mi zona',
      BarrioMapCategory.subscribed => 'Zona suscrita',
      BarrioMapCategory.other => levelShortLabel(alert.level),
    };
  }
}

class _MarkerLabel extends StatelessWidget {
  const _MarkerLabel({
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _truncate(title, 20),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: accent,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: 1.15,
            shadows: const [
              Shadow(color: Colors.white, blurRadius: 4),
              Shadow(color: Colors.white, blurRadius: 2),
            ],
          ),
        ),
        Text(
          _truncate(subtitle, 24),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: accent.withOpacity(0.88),
            fontSize: 11,
            fontWeight: FontWeight.w500,
            height: 1.1,
            shadows: const [
              Shadow(color: Colors.white, blurRadius: 4),
              Shadow(color: Colors.white, blurRadius: 2),
            ],
          ),
        ),
      ],
    );
  }

  String _truncate(String value, int max) {
    if (value.length <= max) return value;
    return '${value.substring(0, max - 1)}…';
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({
    required this.accent,
    required this.icon,
    required this.showSosLabel,
    required this.pulse,
  });

  final Color accent;
  final IconData icon;
  final bool showSosLabel;
  final bool pulse;

  static const _iconDiameter = 22.0;
  static const _pulseDiameter = 30.0;
  /// Baja el icono para que quede dentro de la cabeza blanca del pin.
  static const _iconTopNudge = 4.0;

  /// Centro del círculo superior del pin (misma fórmula que [_MapPinPainter]).
  static double get _headCenterY => kAlertPinWidth * 0.42 + 2;

  @override
  Widget build(BuildContext context) {
    final iconTop = _headCenterY - _iconDiameter / 2 + _iconTopNudge;
    final iconLeft = (kAlertPinWidth - _iconDiameter) / 2;

    return SizedBox(
      width: kAlertPinWidth,
      height: kAlertPinHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: const Size(kAlertPinWidth, kAlertPinHeight),
            painter: _MapPinPainter(accent: accent),
          ),
          if (pulse)
            Positioned(
              left: (kAlertPinWidth - _pulseDiameter) / 2,
              top: _headCenterY - _pulseDiameter / 2 + _iconTopNudge,
              child: Container(
                width: _pulseDiameter,
                height: _pulseDiameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withOpacity(0.18),
                ),
              ),
            ),
          Positioned(
            left: iconLeft,
            top: iconTop,
            child: Container(
              width: _iconDiameter,
              height: _iconDiameter,
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: showSosLabel
                    ? const Text(
                        'SOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 7.5,
                          fontWeight: FontWeight.w800,
                          height: 1,
                          letterSpacing: -0.3,
                        ),
                      )
                    : Icon(
                        icon,
                        size: 13,
                        color: Colors.white,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPinPainter extends CustomPainter {
  _MapPinPainter({required this.accent});

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = _teardropPath(w, h);

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withOpacity(0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withOpacity(0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  Path _teardropPath(double w, double h) {
    final cx = w / 2;
    final headRadius = w * 0.42;
    final headCenterY = headRadius + 2;

    return Path()
      ..moveTo(cx, h)
      ..quadraticBezierTo(w * 0.04, h * 0.58, w * 0.1, headCenterY)
      ..arcToPoint(
        Offset(w - w * 0.1, headCenterY),
        radius: Radius.circular(headRadius),
        clockwise: true,
      )
      ..quadraticBezierTo(w * 0.96, h * 0.58, cx, h)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _MapPinPainter oldDelegate) =>
      oldDelegate.accent != accent;
}
