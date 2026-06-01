// RF-0309: Pantalla para elegir / quitar barrios adicionales
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/constants/milagro_barrios.dart';
import '../providers/subscriptions_provider.dart';
import '../widgets/barrio_subscription_tile.dart';
import '../widgets/subscription_slots_row.dart';

class SubscriptionsManagePage extends ConsumerWidget {
  static const routeName = 'subscriptions-manage';

  const SubscriptionsManagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final homeBarrio = auth.user?.barrio ?? 'Centro';
    final subscribed = ref.watch(barriosSubscribedProvider);
    final canAddMore = ref.watch(canSubscribeMoreProvider);
    final notifier = ref.read(barriosSubscribedProvider.notifier);

    final selectable = kMilagroBarrios.where((b) => b != homeBarrio).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Elegir barrios'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConfig.horizontalMargin),
        children: [
          SubscriptionSlotsRow(
            homeBarrio: homeBarrio,
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
            'Activa los barrios que quieras seguir',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          ...selectable.map((barrio) {
            final isOn = subscribed.contains(barrio);
            return BarrioSubscriptionTile(
              barrio: barrio,
              isSubscribed: isOn,
              enabled: isOn || canAddMore,
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
