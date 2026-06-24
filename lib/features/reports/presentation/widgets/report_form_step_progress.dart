import 'package:centinela_milagro/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

/// Indicador de pasos del formulario de reporte (estilo timeline del detalle).
class ReportFormStepProgress extends StatelessWidget {
  const ReportFormStepProgress({
    super.key,
    required this.currentStep,
  });

  final int currentStep;

  static const _steps = ['Tipo', 'Detalles', 'Confirmar'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          [
            'Selecciona el tipo',
            'Agrega detalles',
            'Confirma tu reporte',
          ][currentStep],
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(_steps.length * 2 - 1, (i) {
            if (i.isOdd) {
              final stepDone = i ~/ 2 < currentStep;
              return Expanded(
                child: Container(
                  height: 2,
                  color: stepDone ? AppConfig.success : AppConfig.border,
                ),
              );
            }

            final step = i ~/ 2;
            final done = step <= currentStep;
            final active = step == currentStep;

            return Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done
                        ? (active && currentStep < _steps.length - 1
                              ? AppConfig.primary.withValues(alpha: 0.2)
                              : AppConfig.success.withValues(alpha: 0.2))
                        : AppConfig.card,
                    border: Border.all(
                      color: done ? AppConfig.success : AppConfig.border,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    done ? Icons.check : Icons.circle,
                    size: done ? 16 : 8,
                    color: done ? AppConfig.success : AppConfig.textTertiary,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 72,
                  child: Text(
                    _steps[step],
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: done
                          ? AppConfig.textPrimary
                          : AppConfig.textTertiary,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}
