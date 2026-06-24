import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';
import 'sos_button_widget.dart';

class HomeSosSectionWidget extends StatelessWidget {
  const HomeSosSectionWidget({
    super.key,
    required this.onEmergencySent,
  });

  final Future<void> Function() onEmergencySent;

  @override
  Widget build(BuildContext context) {
    final height = (MediaQuery.sizeOf(context).height * 0.45).clamp(180, 320);

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConfig.horizontalMargin),
            child: Column(
              children: [
                Text(
                  '¿Necesitas ayuda ahora?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Pulsa el botón para enviar una alerta de emergencia con tu ubicación.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(
            height: height.toDouble(),
            child: Center(
              child: SOSButtonWidget(onEmergencySent: onEmergencySent),
            ),
          ),
        ],
      ),
    );
  }
}
