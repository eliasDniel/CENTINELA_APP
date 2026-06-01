import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';
import '../../domain/constants/milagro_barrios.dart';

/// Visualiza: [Barrio propio] + 3 slots adicionales.
class SubscriptionSlotsRow extends StatelessWidget {
  const SubscriptionSlotsRow({
    super.key,
    required this.homeBarrio,
    required this.subscribedBarrios,
  });

  final String homeBarrio;
  final List<String> subscribedBarrios;

  @override
  Widget build(BuildContext context) {
    final slots = List<String?>.filled(kMaxBarriosAdicionales, null);
    for (var i = 0; i < subscribedBarrios.length && i < kMaxBarriosAdicionales; i++) {
      slots[i] = subscribedBarrios[i];
    }

    return Row(
      children: [
        Expanded(child: _SlotChip(label: homeBarrio, isHome: true, isEmpty: false)),
        const SizedBox(width: 8),
        ...slots.map(
          (barrio) => Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _SlotChip(
                label: barrio ?? 'Vacío',
                isHome: false,
                isEmpty: barrio == null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.label,
    required this.isHome,
    required this.isEmpty,
  });

  final String label;
  final bool isHome;
  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    final color = isHome
        ? AppConfig.success
        : isEmpty
            ? AppConfig.textTertiary
            : AppConfig.primary;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(isEmpty ? 0.08 : 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEmpty ? AppConfig.border : color.withOpacity(0.6),
          width: isEmpty ? 1 : 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isHome
                ? Icons.home_rounded
                : isEmpty
                    ? Icons.add_circle_outline
                    : Icons.location_on,
            size: 18,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            isEmpty ? 'Libre' : label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isEmpty ? AppConfig.textTertiary : Colors.white,
            ),
          ),
          if (isHome)
            Text(
              'Propio',
              style: TextStyle(fontSize: 9, color: AppConfig.success.withOpacity(0.9)),
            ),
        ],
      ),
    );
  }
}
