// RF-0306: Mock map painter - CustomPainter for street grid
import 'package:flutter/material.dart';
import '../../domain/entities/map_marker_entity.dart';
import '../../../../core/utils/app_colors.dart';

class MockMapPainter extends CustomPainter {
  final List<MapMarkerEntity> markers;
  final Function(MapMarkerEntity)? onMarkerTap;

  MockMapPainter({required this.markers, this.onMarkerTap});

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF0A1628),
    );

    // Draw street grid
    final gridPaint = Paint()
      ..color = const Color(0xFF2A3F5F)
      ..strokeWidth = 1;

    // Vertical streets
    for (int i = 0; i < 20; i++) {
      final x = (size.width / 20) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Horizontal streets
    for (int i = 0; i < 20; i++) {
      final y = (size.height / 20) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw building blocks (light gray)
    final blockPaint = Paint()
      ..color = const Color(0xFF1A2F4D)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 10; i++) {
      for (int j = 0; j < 10; j++) {
        final x = (size.width / 10) * i + 4;
        final y = (size.height / 10) * j + 4;
        canvas.drawRect(
          Rect.fromLTWH(x, y, size.width / 10 - 8, size.height / 10 - 8),
          blockPaint,
        );
      }
    }

    // Draw markers
    for (final marker in markers) {
      _drawMarker(canvas, size, marker);
    }
  }

  void _drawMarker(Canvas canvas, Size size, MapMarkerEntity marker) {
    // Normalize coordinates to canvas
    final x = ((marker.longitude + 79.57) * 1000) % size.width;
    final y = ((marker.latitude + 2.13) * 1000) % size.height;

    final color = _getColorForType(marker.type);

    // Draw marker circle
    canvas.drawCircle(
      Offset(x, y),
      12,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );

    // Draw marker border
    canvas.drawCircle(
      Offset(x, y),
      12,
      Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Draw icon-like indicator
    canvas.drawCircle(
      Offset(x, y),
      6,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'emergencia':
        return AppColors.error;
      case 'alerta':
        return AppColors.warning;
      case 'incidente_menor':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  bool shouldRepaint(MockMapPainter oldDelegate) {
    return oldDelegate.markers != markers;
  }
}
