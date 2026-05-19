// RF-0307: Summary statistics row with 3 stat chips
import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';

class StatSummaryRow extends StatelessWidget {
  final int emergencias;
  final int alertas;
  final int menores;

  const StatSummaryRow({
    super.key,
    required this.emergencias,
    required this.alertas,
    required this.menores,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatChip(
            icon: '🔴',
            number: emergencias.toString(),
            label: 'Emergencias',
            color: AppConfig.sos,
          ),
          _StatChip(
            icon: '🟡',
            number: alertas.toString(),
            label: 'Alertas',
            color: AppConfig.warning,
          ),
          _StatChip(
            icon: '🔵',
            number: menores.toString(),
            label: 'Menores',
            color: AppConfig.primary,
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String icon;
  final String number;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.number,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: AppConfig.surface,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(
            number,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppConfig.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
