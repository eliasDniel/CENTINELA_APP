// RF-0306: aviso breve del radio de cobertura (se oculta solo)
import 'package:flutter/material.dart';

class RadiusHintChip extends StatelessWidget {
  const RadiusHintChip({super.key, required this.radiusKm});

  final int radiusKm;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.78),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.radar, size: 16, color: Colors.blue.shade300),
            const SizedBox(width: 8),
            Text(
              'Cerca de ti · $radiusKm km',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
