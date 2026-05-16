// RF-0306: leyenda del mapa con niveles y fuentes
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/map_provider.dart';

class MapLegendWidget extends ConsumerWidget {
  const MapLegendWidget({super.key});

  Color _levelColor(String level) {
    switch (level) {
      case 'emergencia':
        return const Color(0xFFFF3B30);
      case 'alerta':
        return const Color(0xFFFF9500);
      case 'vigilancia':
      default:
        return const Color(0xFF1E90FF);
    }
  }

  Widget _row({required Color color, required String label, String? value}) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value == null ? label : '$label · $value',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(alertCountProvider);

    return Positioned(
      left: 12,
      bottom: 18,
      child: Container(
        width: 190,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.75),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'NIVELES',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 10),
            _row(color: _levelColor('emergencia'), label: 'Emergencia', value: '${counts['emergencia'] ?? 0}'),
            const SizedBox(height: 8),
            _row(color: _levelColor('alerta'), label: 'Alerta', value: '${counts['alerta'] ?? 0}'),
            const SizedBox(height: 8),
            _row(color: _levelColor('vigilancia'), label: 'Vigilancia', value: '${counts['vigilancia'] ?? 0}'),
            const SizedBox(height: 10),
            const Divider(color: Colors.white24, height: 16),
            const Text(
              'FUENTES',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 10),
            const Text('🤖 Sensor IoT', style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 6),
            const Text('👤 Ciudadano', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
