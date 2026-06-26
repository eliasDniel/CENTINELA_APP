// RF-0309: Centro de suscripciones a zonas
import 'dart:async';

import 'package:centinela_milagro/features/auth/domain/entities/zona_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_alert.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../map/presentation/providers/map_provider.dart';
import '../../../profile/presentation/pages/change_location_page.dart';
import '../../domain/constants/zona_suscripcion_limits.dart';
import '../providers/zonas_suscripciones_provider.dart';
import '../widgets/zona_subscription_slots_row.dart';
import '../widgets/zona_subscription_tile.dart';

class SubscriptionsHubPage extends ConsumerWidget {
  static const routeName = 'subscriptions';

  const SubscriptionsHubPage({super.key});

  List<ZonaEntity> _zonesForList(ZonasSuscripcionesState state) {
    final principalId = state.principalZona?.zonaId;
    final zones = state.catalog.where((z) => z.id != principalId).toList();
    zones.sort((a, b) {
      final aSub = state.subscribedIds.contains(a.id);
      final bSub = state.subscribedIds.contains(b.id);
      if (aSub != bSub) return aSub ? -1 : 1;
      return a.nombre.compareTo(b.nombre);
    });
    return zones;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(zonasSuscripcionesProvider);
    final notifier = ref.read(zonasSuscripcionesProvider.notifier);
    final principal = state.principalZona;
    final subscribed = state.subscribedZonas;
    final zonesForList = _zonesForList(state);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis zonas'),
        actions: [
          IconButton(
            onPressed: state.isLoading || state.isMutating
                ? null
                : () => unawaited(notifier.load()),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: notifier.load,
        child: ListView(
          padding: const EdgeInsets.all(AppConfig.horizontalMargin),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const _InfoCard(),
            const SizedBox(height: 20),
            if (state.isLoading && state.catalog.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.errorMessage != null && state.catalog.isEmpty)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.error_outline, color: AppConfig.error),
                  title: const Text('No se pudieron cargar las zonas'),
                  subtitle: Text(state.errorMessage!),
                  trailing: TextButton(
                    onPressed: () => unawaited(notifier.load()),
                    child: const Text('Reintentar'),
                  ),
                ),
              )
            else ...[
              Text('Tu cobertura', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 10),
              ZonaSubscriptionSlotsRow(
                principalLabel: principal?.zona.nombre ?? 'Sin zona principal',
                subscribedLabels: subscribed.map((z) => z.zona.nombre).toList(),
              ),
              const SizedBox(height: 8),
              Text(
                '${subscribed.length} de $kMaxZonasSuscritas zonas adicionales',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: state.canSubscribeMore
                      ? AppConfig.textSecondary
                      : AppConfig.warning,
                ),
              ),
              const SizedBox(height: 24),
              if (principal != null) ...[
                Text('Zona principal', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                ZonaSubscriptionTile(
                  nombre: principal.zona.nombre,
                  isSubscribed: true,
                  enabled: false,
                  isPrincipal: true,
                  onChanged: (_) {},
                ),
                const SizedBox(height: 20),
              ],
              Text('Todas las zonas', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              if (zonesForList.isEmpty)
                Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.info_outline,
                      color: AppConfig.textTertiary,
                    ),
                    title: const Text('Sin otras zonas'),
                    subtitle: const Text(
                      'Solo tienes configurada tu zona principal.',
                    ),
                  ),
                )
              else
                ...zonesForList.map((zona) {
                  final isSubscribed = state.subscribedIds.contains(zona.id);
                  return ZonaSubscriptionTile(
                    nombre: zona.nombre,
                    isSubscribed: isSubscribed,
                    enabled:
                        (isSubscribed || state.canSubscribeMore) &&
                        !state.isMutating,
                    subtitle: zona.descripcion.isNotEmpty
                        ? zona.descripcion
                        : 'Riesgo nivel ${zona.riesgoNivel}',
                    onChanged: (value) => _onToggle(
                      context,
                      ref,
                      zona: zona,
                      subscribe: value,
                    ),
                  );
                }),
              if (!state.canSubscribeMore) ...[
                const SizedBox(height: 8),
                Card(
                  color: AppConfig.warning.withOpacity(0.12),
                  child: const ListTile(
                    leading: Icon(Icons.info_outline, color: AppConfig.warning),
                    title: Text('Límite alcanzado'),
                    subtitle: Text(
                      'Quita una zona suscrita para poder agregar otra.',
                    ),
                  ),
                ),
              ],
            ],
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push(
                '/home/${GoRouterState.of(context).pathParameters['page'] ?? '3'}/${ChangeLocationPage.routeName}',
              ),
              icon: const Icon(Icons.edit_location_alt_outlined),
              label: const Text('Cambiar zona principal'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => context.go('/home/1'),
              icon: const Icon(Icons.map_outlined),
              label: const Text('Ver alertas en el mapa'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onToggle(
    BuildContext context,
    WidgetRef ref, {
    required ZonaEntity zona,
    required bool subscribe,
  }) async {
    if (!subscribe) {
      _confirmUnsubscribe(
        context,
        zona.nombre,
        () => unawaited(_applyToggle(context, ref, zona: zona, subscribe: false)),
      );
      return;
    }

    await _applyToggle(context, ref, zona: zona, subscribe: true);
  }

  Future<void> _applyToggle(
    BuildContext context,
    WidgetRef ref, {
    required ZonaEntity zona,
    required bool subscribe,
  }) async {
    final notifier = ref.read(zonasSuscripcionesProvider.notifier);
    final ok = subscribe
        ? await notifier.subscribe(zona.id)
        : await notifier.unsubscribe(zona.id);

    if (!context.mounted) return;

    if (ok) {
      if (ref.exists(mapProvider)) {
        unawaited(ref.read(mapProvider.notifier).refreshAlerts());
      }
      if (!subscribe) {
        AppAlert.success(context, 'Zona desuscrita');
      }
      return;
    }

    final error = ref.read(zonasSuscripcionesProvider).errorMessage;
    if (error != null && error.isNotEmpty) {
      AppAlert.warning(context, error);
      return;
    }

    if (subscribe) {
      AppAlert.warning(
        context,
        'Máximo $kMaxZonasSuscritas zonas adicionales. Quita una primero.',
      );
    }
  }

  void _confirmUnsubscribe(
    BuildContext context,
    String nombre,
    VoidCallback onConfirm,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('¿Dejar de seguir $nombre?'),
        content: const Text(
          'Ya no recibirás alertas de esa zona en tu mapa ni en tus filtros.',
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
            child: const Text(
              'Quitar',
              style: TextStyle(color: AppConfig.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard();

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
              text: 'Tu zona principal siempre recibe alertas.',
            ),
            _StepRow(
              number: '2',
              text:
                  'Activa hasta $kMaxZonasSuscritas zonas adicionales desde la lista.',
            ),
            const _StepRow(
              number: '3',
              text: 'En el mapa filtra alertas por tus zonas suscritas.',
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
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
