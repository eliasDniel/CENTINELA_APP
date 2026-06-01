import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Marcador con haz direccional (brújula).
class UserLocationMarker extends StatelessWidget {
  const UserLocationMarker({
    super.key,
    required this.headingDegrees,
    required this.beamPointsUpOnScreen,
    this.showBeam = true,
  });

  /// Orientación del dispositivo (norte = 0°).
  final double headingDegrees;

  /// Modo brújula: el mapa ya giró, el haz apunta hacia arriba en pantalla.
  final bool beamPointsUpOnScreen;

  final bool showBeam;

  @override
  Widget build(BuildContext context) {
    if (!showBeam) {
      return const SizedBox(
        width: 28,
        height: 28,
        child: _SimpleUserDot(),
      );
    }

    const size = 72.0;

    Widget marker = CustomPaint(
      size: const Size(size, size),
      painter: _UserLocationPainter(showBeam: true),
    );

    if (!beamPointsUpOnScreen) {
      marker = Transform.rotate(
        angle: headingDegrees * math.pi / 180,
        child: marker,
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: marker,
    );
  }
}

class _UserLocationPainter extends CustomPainter {
  _UserLocationPainter({required this.showBeam});

  final bool showBeam;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    if (showBeam) {
      final beamPath = Path()
        ..moveTo(center.dx, center.dy - 4)
        ..lineTo(center.dx - 14, center.dy + 22)
        ..lineTo(center.dx + 14, center.dy + 22)
        ..close();

      final beamPaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.9),
          radius: 1.1,
          colors: [
            const Color(0xFF42A5F5).withOpacity(0.55),
            const Color(0xFF42A5F5).withOpacity(0.08),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: 36));

      canvas.drawPath(beamPath, beamPaint);

      final glowPaint = Paint()
        ..color = const Color(0xFF42A5F5).withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawPath(beamPath, glowPaint);
    }

    canvas.drawCircle(
      center,
      16,
      Paint()..color = const Color(0xFF42A5F5).withOpacity(0.18),
    );

    canvas.drawCircle(
      center,
      7,
      Paint()
        ..color = const Color(0xFF42A5F5)
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      center,
      7,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(covariant _UserLocationPainter oldDelegate) =>
      oldDelegate.showBeam != showBeam;
}

class _SimpleUserDot extends StatelessWidget {
  const _SimpleUserDot();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF42A5F5),
          border: Border.all(color: Colors.white, width: 2.5),
        ),
      ),
    );
  }
}
