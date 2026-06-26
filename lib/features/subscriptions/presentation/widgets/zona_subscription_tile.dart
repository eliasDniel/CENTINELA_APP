import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';

class ZonaSubscriptionTile extends StatelessWidget {
  const ZonaSubscriptionTile({
    super.key,
    required this.nombre,
    required this.isSubscribed,
    required this.enabled,
    required this.onChanged,
    this.subtitle,
    this.isPrincipal = false,
    this.trailing,
  });

  final String nombre;
  final bool isSubscribed;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  final String? subtitle;
  final bool isPrincipal;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final accent = isPrincipal ? AppConfig.success : AppConfig.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        enabled: enabled || isSubscribed,
        leading: CircleAvatar(
          backgroundColor: accent.withOpacity(0.2),
          child: Icon(
            isPrincipal ? Icons.home_rounded : Icons.map_outlined,
            color: accent,
            size: 22,
          ),
        ),
        title: Text(nombre),
        subtitle: Text(
          subtitle ??
              (isPrincipal
                  ? 'Tu zona principal'
                  : isSubscribed
                  ? 'Recibirás alertas de esta zona'
                  : 'Toca para suscribirte'),
        ),
        trailing:
            trailing ??
            (isPrincipal
                ? Chip(
                    label: const Text('Principal'),
                    backgroundColor: AppConfig.success.withOpacity(0.15),
                    labelStyle: const TextStyle(
                      color: AppConfig.success,
                      fontSize: 12,
                    ),
                  )
                : Switch.adaptive(
                    value: isSubscribed,
                    activeColor: accent,
                    onChanged: enabled || isSubscribed ? onChanged : null,
                  )),
        onTap: isPrincipal || (!enabled && !isSubscribed)
            ? null
            : () => onChanged(!isSubscribed),
      ),
    );
  }
}
