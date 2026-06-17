// RF-0309: Pantalla para elegir / quitar barrios adicionales
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/constants/zonas_administrativas.dart';
import '../providers/subscriptions_provider.dart';
import '../widgets/barrio_subscription_tile.dart';
import '../widgets/subscription_slots_row.dart';

class SubscriptionsManagePage extends ConsumerWidget {
  static const routeName = 'subscriptions-manage';

  const SubscriptionsManagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final homeZona = auth.user?.zona ?? 'Milagro';
    final homeBarrio = auth.user?.barrio ?? '';
    final subscribed = ref.watch(barriosSubscribedProvider);
    final canAddMore = ref.watch(canSubscribeMoreProvider);
    final notifier = ref.read(barriosSubscribedProvider.notifier);
    final selectable = ref.watch(selectableBarriosEnZonaProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Elegir barrios')),
      body: ListView(
        padding: const EdgeInsets.all(AppConfig.horizontalMargin),
        children: [
          Text(
            'Zona: $homeZona',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: AppConfig.primary),
          ),
          const SizedBox(height: 12),
          SubscriptionSlotsRow(
            homeZona: homeZona,
            homeBarrio: homeBarrio.isNotEmpty ? homeBarrio : null,
            subscribedBarrios: subscribed,
          ),
          const SizedBox(height: 8),
          Text(
            '${subscribed.length}/$kMaxBarriosAdicionales cupos usados',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: canAddMore ? AppConfig.textSecondary : AppConfig.warning,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Barrios disponibles en $homeZona',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          if (selectable.isEmpty)
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.info_outline,
                  color: AppConfig.textTertiary,
                ),
                title: const Text('Sin barrios adicionales'),
                subtitle: Text(
                  zonaTieneBarrios(homeZona)
                      ? 'Ya estás suscrito a todos los barrios de tu zona.'
                      : 'Esta zona no tiene barrios específicos.',
                ),
              ),
            )
          else
            ...selectable.map((barrio) {
              final isOn = subscribed.contains(barrio);
              return BarrioSubscriptionTile(
                barrio: barrio,
                isSubscribed: isOn,
                enabled: isOn || canAddMore,
                subtitle: 'Zona $homeZona',
                onChanged: (value) {
                  if (value) {
                    final ok = notifier.subscribe(barrio, homeBarrio);
                    if (!ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Máximo 3 barrios adicionales. Quita uno primero.',
                          ),
                        ),
                      );
                    }
                  } else {
                    notifier.unsubscribe(barrio);
                  }
                },
              );
            }),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConfig.horizontalMargin),
          child: FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              subscribed.isEmpty
                  ? 'Guardar sin barrios extra'
                  : 'Listo (${subscribed.length} suscritos)',
            ),
          ),
        ),
      ),
    );
  }
}
