import 'dart:async';

import 'package:centinela_milagro/features/auth/domain/entities/zona_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../map/presentation/providers/map_provider.dart';
import '../../../subscriptions/presentation/providers/zonas_suscripciones_provider.dart';
import '../../../../core/utils/app_alert.dart';
import '../../../../core/utils/app_colors.dart';

class ChangeLocationPage extends ConsumerStatefulWidget {
  static const routeName = 'change-location';

  const ChangeLocationPage({super.key});

  @override
  ConsumerState<ChangeLocationPage> createState() => _ChangeLocationPageState();
}

class _ChangeLocationPageState extends ConsumerState<ChangeLocationPage> {
  String? _selectedZonaId;
  String? _zonaError;
  bool _loading = false;
  bool _initialized = false;

  void _ensureInitialized({
    required String? currentZonaId,
    required List<ZonaEntity> catalog,
    required String? principalZonaId,
  }) {
    if (_initialized || catalog.isEmpty) return;

    if (currentZonaId != null && currentZonaId.isNotEmpty) {
      _selectedZonaId = catalog.any((z) => z.id == currentZonaId)
          ? currentZonaId
          : principalZonaId ?? catalog.first.id;
    } else {
      _selectedZonaId = principalZonaId ?? catalog.first.id;
    }

    _initialized = true;
  }

  ZonaEntity? _selectedZona(List<ZonaEntity> catalog) {
    final selectedId = _selectedZonaId;
    if (selectedId == null) return null;
    for (final zona in catalog) {
      if (zona.id == selectedId) return zona;
    }
    return null;
  }

  Future<void> _save(List<ZonaEntity> catalog) async {
    final selected = _selectedZona(catalog);

    setState(() {
      _zonaError = selected == null ? 'Selecciona una zona' : null;
    });

    if (selected == null) return;

    final user = ref.read(authProvider).user;
    final currentZonaId = user?.zonaId ?? '';
    if (currentZonaId == selected.id) {
      if (mounted) context.pop();
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cambiar zona principal?'),
        content: Text(
          'Tu zona principal pasará a ser ${selected.nombre}. '
          'La zona anterior puede quedar como suscripción adicional '
          'si aún tienes cupo disponible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cambiar zona'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _loading = true);

    final ok = await ref
        .read(zonasSuscripcionesProvider.notifier)
        .setPrincipal(selected.id);

    if (!mounted) return;

    if (!ok) {
      setState(() => _loading = false);
      final error = ref.read(zonasSuscripcionesProvider).errorMessage;
      if (error != null && error.isNotEmpty) {
        AppAlert.error(context, error);
      }
      return;
    }

    final authError = await ref.read(authProvider.notifier).updatePrincipalZona(
      zonaId: selected.id,
      zonaNombre: selected.nombre,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (authError != null) {
      AppAlert.error(context, authError);
      return;
    }

    if (ref.exists(mapProvider)) {
      unawaited(ref.read(mapProvider.notifier).refreshAlerts());
    }

    AppAlert.success(context, 'Zona principal actualizada: ${selected.nombre}');
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final zonasState = ref.watch(zonasSuscripcionesProvider);
    final catalog = zonasState.catalog;
    final principalZonaId = zonasState.principalZona?.zonaId;

    _ensureInitialized(
      currentZonaId: user?.zonaId,
      catalog: catalog,
      principalZonaId: principalZonaId,
    );

    final ubicacionActual = user?.zonaNombre?.isNotEmpty == true
        ? user!.zonaNombre!
        : 'Sin zona principal';

    return Scaffold(
      appBar: AppBar(title: const Text('Cambiar zona principal')),
      body: zonasState.isLoading && catalog.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : zonasState.errorMessage != null && catalog.isEmpty
          ? ListView(
              padding: const EdgeInsets.all(AppConfig.horizontalMargin),
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.error_outline,
                      color: AppConfig.error,
                    ),
                    title: const Text('No se pudieron cargar las zonas'),
                    subtitle: Text(zonasState.errorMessage!),
                    trailing: TextButton(
                      onPressed: zonasState.isLoading
                          ? null
                          : () => unawaited(
                              ref
                                  .read(zonasSuscripcionesProvider.notifier)
                                  .load(),
                            ),
                      child: const Text('Reintentar'),
                    ),
                  ),
                ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.all(AppConfig.horizontalMargin),
              children: [
                Card(
                  child: ListTile(
                    leading: Icon(Icons.my_location, color: AppConfig.primary),
                    title: const Text('Zona principal actual'),
                    subtitle: Text(ubicacionActual),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Nueva zona principal',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: catalog.any((z) => z.id == _selectedZonaId)
                      ? _selectedZonaId
                      : null,
                  decoration: InputDecoration(
                    labelText: 'Zona del cantón',
                    errorText: _zonaError,
                  ),
                  items: catalog
                      .map(
                        (zona) => DropdownMenuItem(
                          value: zona.id,
                          child: Text(zona.nombre),
                        ),
                      )
                      .toList(),
                  onChanged: _loading || zonasState.isMutating
                      ? null
                      : (value) {
                          setState(() {
                            _selectedZonaId = value;
                            _zonaError = null;
                          });
                        },
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConfig.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppConfig.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppConfig.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Las alertas del mapa y tus notificaciones se '
                          'ajustarán a tu nueva zona principal.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppConfig.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: _loading || zonasState.isMutating
                      ? null
                      : () => _save(catalog),
                  child: _loading || zonasState.isMutating
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar cambios'),
                ),
              ],
            ),
    );
  }
}
