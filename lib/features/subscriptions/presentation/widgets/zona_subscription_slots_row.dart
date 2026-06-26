import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';
import '../../domain/constants/zona_suscripcion_limits.dart';

/// Visualiza: [Zona principal] arriba + cupos de zonas suscritas abajo.
class ZonaSubscriptionSlotsRow extends StatelessWidget {
  const ZonaSubscriptionSlotsRow({
    super.key,
    required this.principalLabel,
    required this.subscribedLabels,
  });

  final String principalLabel;
  final List<String> subscribedLabels;

  @override
  Widget build(BuildContext context) {
    final slots = List<String?>.filled(kMaxZonasSuscritas, null);
    for (var i = 0;
        i < subscribedLabels.length && i < kMaxZonasSuscritas;
        i++) {
      slots[i] = subscribedLabels[i];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SlotChip(
          label: principalLabel,
          isHome: true,
          isEmpty: false,
          expanded: true,
        ),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < slots.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _SlotChip(
                    label: slots[i] ?? 'Vacío',
                    isHome: false,
                    isEmpty: slots[i] == null,
                  ),
                ),
              ],
            ],
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
    this.expanded = false,
  });

  final String label;
  final bool isHome;
  final bool isEmpty;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final color = isHome
        ? AppConfig.success
        : isEmpty
        ? AppConfig.textTertiary
        : AppConfig.primary;

    final badge = isHome ? 'Principal' : (isEmpty ? null : 'Suscrita');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: expanded ? 14 : 8,
        vertical: expanded ? 12 : 10,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(isEmpty ? 0.08 : 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEmpty ? AppConfig.border : color.withOpacity(0.6),
          width: isEmpty ? 1 : 1.5,
        ),
      ),
      child: expanded
          ? Row(
              children: [
                Icon(Icons.home_rounded, size: 22, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.25,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          badge,
                          style: TextStyle(
                            fontSize: 11,
                            color: color.withOpacity(0.95),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isEmpty ? Icons.add_circle_outline : Icons.map_outlined,
                  size: 18,
                  color: color,
                ),
                const SizedBox(height: 6),
                Text(
                  isEmpty ? 'Libre' : label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    color: isEmpty ? AppConfig.textTertiary : Colors.white,
                  ),
                ),
                if (badge != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    badge,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      height: 1.1,
                      color: color.withOpacity(0.9),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
