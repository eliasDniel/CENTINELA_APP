import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';

Color barrioAccentColor(String barrio) {
  return switch (barrio) {
    'Norte' => const Color(0xFF5856D6),
    'Sur' => const Color(0xFFFF2D55),
    'Centro' => AppConfig.warning,
    'Este' => AppConfig.success,
    'Oeste' => AppConfig.primary,
    _ => AppConfig.textTertiary,
  };
}

class BarrioSubscriptionTile extends StatelessWidget {
  const BarrioSubscriptionTile({
    super.key,
    required this.barrio,
    required this.isSubscribed,
    required this.enabled,
    required this.onChanged,
    this.subtitle,
  });

  final String barrio;
  final bool isSubscribed;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final accent = barrioAccentColor(barrio);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        enabled: enabled || isSubscribed,
        leading: CircleAvatar(
          backgroundColor: accent.withOpacity(0.2),
          child: Icon(Icons.location_city, color: accent, size: 22),
        ),
        title: Text(barrio),
        subtitle: Text(
          subtitle ??
              (isSubscribed
                  ? 'Recibirás alertas de este barrio'
                  : 'Toca para suscribirte'),
        ),
        trailing: Switch.adaptive(
          value: isSubscribed,
          activeColor: accent,
          onChanged: enabled || isSubscribed ? onChanged : null,
        ),
        onTap: enabled || isSubscribed ? () => onChanged(!isSubscribed) : null,
      ),
    );
  }
}
