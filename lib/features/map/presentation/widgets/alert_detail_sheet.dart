// RF-0306: detalle expandible de la alerta seleccionada
import 'package:flutter/material.dart';

import '../../domain/entities/map_alert_entity.dart';

class AlertDetailSheet extends StatelessWidget {
  final MapAlertEntity alert;
  final VoidCallback onCenterMap;

  const AlertDetailSheet({
    super.key,
    required this.alert,
    required this.onCenterMap,
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

  String _levelText(AlertLevel level) {
    switch (level) {
      case AlertLevel.emergencia:
        return 'Emergencia';
      case AlertLevel.alerta:
        return 'Alerta';
      case AlertLevel.vigilancia:
        return 'Vigilancia';
    }
  }

  String _sourceText(AlertSource source) {
    switch (source) {
      case AlertSource.sensor_audio:
        return 'Sensor IoT';
      case AlertSource.sensor_video:
        return 'Sensor IoT';
      case AlertSource.sensor_hidrico:
        return 'Hidrológico';
      case AlertSource.ciudadano:
        return 'Ciudadano';
    }
  }

  String _typeText(AlertType type) {
    switch (type) {
      case AlertType.disparo:
        return 'Disparo';
      case AlertType.explosion:
        return 'Explosión';
      case AlertType.grito:
        return 'Grito';
      case AlertType.vidrio_roto:
        return 'Vidrio roto';
      case AlertType.alarma_vehiculo:
        return 'Alarma de vehículo';
      case AlertType.nivel_hidrico:
        return 'Nivel hídrico';
      case AlertType.reporte_ciudadano:
        return 'Reporte ciudadano';
      case AlertType.sos:
        return 'SOS';
    }
  }

  String _timeAgo(DateTime timestamp) {
    final minutes = DateTime.now().difference(timestamp).inMinutes;
    if (minutes < 1) return 'hace unos segundos';
    return 'hace $minutes min';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.55,
      maxChildSize: 0.96,
      expand: false,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF10131A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            controller: controller,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 46,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _Badge(
                        label: _levelText(alert.level),
                        color: _levelColor(alert.level),
                      ),
                      _Badge(
                        label: _sourceText(alert.source),
                        color: const Color(0xFF5A5A6E),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _typeText(alert.type),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    alert.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF171C26),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('📍 Barrio: ${alert.barrio}', style: const TextStyle(color: Colors.white)),
                        const SizedBox(height: 8),
                        Text('🕐 ${_timeAgo(alert.timestamp)}', style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 8),
                        Text('📡 Fuente del dato: ${_sourceText(alert.source)}', style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (alert.source == AlertSource.sensor_audio || alert.source == AlertSource.sensor_video)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF121A22),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFF223041)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🤖 Detectado por IA — YAMNet/YOLOv8n', style: TextStyle(color: Colors.white)),
                          const SizedBox(height: 6),
                          Text(
                            'Confianza: ${(alert.confidence ?? 0.85).toStringAsFixed(2)} | Nodo: ${alert.nodeId ?? 'N/A'}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  if (alert.source == AlertSource.sensor_hidrico)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B2138),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFF154A75)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🌊 Sensor JSN-SR04T', style: TextStyle(color: Colors.white)),
                          const SizedBox(height: 6),
                          Text(
                            'Nivel actual: +${(alert.waterLevelDelta ?? 0).toStringAsFixed(1)}m sobre umbral',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  if (alert.source == AlertSource.ciudadano)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF23172F),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFF4B2D66)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('👤 Reporte ciudadano anónimo', style: TextStyle(color: Colors.white)),
                          const SizedBox(height: 6),
                          Text(
                            'Pseudónimo: ${alert.pseudonym ?? 'anon-0000'}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 14),
                  Text(
                    '📍 GPS: ${alert.lat.toStringAsFixed(4)}, ${alert.lng.toStringAsFixed(4)}',
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _levelColor(alert.level),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: onCenterMap,
                      icon: const Icon(Icons.center_focus_strong_rounded),
                      label: const Text('Ver en contexto'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}