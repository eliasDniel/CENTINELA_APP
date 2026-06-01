// RF-0309: Centro de suscripciones a barrios
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/constants/milagro_barrios.dart';
import '../providers/subscriptions_provider.dart';
import '../widgets/barrio_subscription_tile.dart';
import '../widgets/subscription_slots_row.dart';
import 'subscriptions_manage_page.dart';

class SubscriptionsHubPage extends ConsumerWidget {
  static const routeName = 'subscriptions';

  const SubscriptionsHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final homeBarrio = auth.user?.barrio ?? 'Centro';
    final subscribed = ref.watch(barriosSubscribedProvider);
    final slotsUsed = ref.watch(subscriptionSlotsUsedProvider);
    final canAddMore = ref.watch(canSubscribeMoreProvider);
    final notifier = ref.read(barriosSubscribedProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis barrios'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConfig.horizontalMargin),
        children: [
          _InfoCard(),
          const SizedBox(height: 20),
          Text('Tu cobertura', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          SubscriptionSlotsRow(
            homeBarrio: homeBarrio,
            subscribedBarrios: subscribed,
          ),
          const SizedBox(height: 8),
          Text(
            '$slotsUsed de $kMaxBarriosAdicionales barrios adicionales',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppConfig.textSecondary,
                ),
          ),
          const SizedBox(height: 24),
          if (subscribed.isNotEmpty) ...[
            Text(
              'Barrios adicionales',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ...subscribed.map(
              (barrio) => Card(
                child: ListTile(
                  leading: Icon(
                    Icons.notifications_active,
                    color: barrioAccentColor(barrio),
                  ),
                  title: Text(barrio),
                  subtitle: const Text('Alertas activas'),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, color: AppConfig.error),
                    onPressed: () => _confirmUnsubscribe(
                      context,
                      barrio,
                      () => notifier.unsubscribe(barrio),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (canAddMore)
            FilledButton.icon(
              onPressed: () => context.push(
                '/home/${GoRouterState.of(context).pathParameters['page'] ?? '3'}/subscriptions/manage',
              ),
              icon: const Icon(Icons.add_location_alt),
              label: Text(
                subscribed.isEmpty
                    ? 'Suscribir primer barrio'
                    : 'Agregar otro barrio',
              ),
            )
          else
            Card(
              color: AppConfig.warning.withOpacity(0.12),
              child: const ListTile(
                leading: Icon(Icons.info_outline, color: AppConfig.warning),
                title: Text('Límite alcanzado'),
                subtitle: Text(
                  'Quita un barrio para poder agregar otro distinto.',
                ),
              ),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: subscribed.isEmpty
                ? null
                : () {
                    context.go('/home/1');
                  },
            icon: const Icon(Icons.map_outlined),
            label: const Text('Ver alertas en el mapa'),
          ),
        ],
      ),
    );
  }

  void _confirmUnsubscribe(
    BuildContext context,
    String barrio,
    VoidCallback onConfirm,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('¿Dejar de seguir $barrio?'),
        content: const Text(
          'Ya no recibirás alertas ni verás incidentes de ese barrio en tu feed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(ctx);
            },
            child: const Text('Quitar', style: TextStyle(color: AppConfig.error)),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shield_outlined, color: AppConfig.primary),
                const SizedBox(width: 10),
                Text(
                  '¿Cómo funciona?',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const _StepRow(
              number: '1',
              text: 'Tu barrio de registro siempre recibe alertas.',
            ),
            _StepRow(
              number: '2',
              text:
                  'Elige hasta $kMaxBarriosAdicionales barrios más (familia, trabajo, etc.).',
            ),
            const _StepRow(
              number: '3',
              text: 'En el mapa activa "Solo mis barrios" para filtrar.',
            ),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppConfig.primary.withOpacity(0.2),
            child: Text(
              number,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppConfig.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
