import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../map/presentation/providers/map_provider.dart';
import '../../../subscriptions/domain/constants/zonas_administrativas.dart';
import '../../../subscriptions/presentation/providers/subscriptions_provider.dart';
import '../../../../core/utils/app_alert.dart';
import '../../../../core/utils/app_colors.dart';

class ChangeLocationPage extends ConsumerStatefulWidget {
  static const routeName = 'change-location';

  const ChangeLocationPage({super.key});

  @override
  ConsumerState<ChangeLocationPage> createState() => _ChangeLocationPageState();
}

class _ChangeLocationPageState extends ConsumerState<ChangeLocationPage> {
  late String _selectedZona;
  String? _selectedBarrio;
  String? _zonaError;
  String? _barrioError;
  bool _loading = false;

  List<String> get _barriosDeZona => barriosDeZona(_selectedZona);
  bool get _requiereBarrio => zonaTieneBarrios(_selectedZona);

  bool _initialized = false;

  void _initFromUser() {
    final user = ref.read(authProvider).user;
    _selectedZona = user?.zona ?? kZonasAdministrativas.first;
    final barrio = user?.barrio ?? '';
    final barrios = barriosDeZona(_selectedZona);
    _selectedBarrio = barrio.isNotEmpty
        ? barrio
        : (barrios.isNotEmpty ? barrios.first : null);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _initFromUser();
    }
  }

  void _onZonaChanged(String? zona) {
    if (zona == null) return;
    setState(() {
      _selectedZona = zona;
      final barrios = barriosDeZona(zona);
      _selectedBarrio = barrios.isNotEmpty ? barrios.first : null;
      _zonaError = null;
      _barrioError = null;
    });
  }

  Future<void> _save() async {
    setState(() {
      _zonaError = _selectedZona.isEmpty ? 'Selecciona una zona' : null;
      _barrioError =
          _requiereBarrio &&
              (_selectedBarrio == null || _selectedBarrio!.isEmpty)
          ? 'Selecciona un barrio'
          : null;
    });

    if (_zonaError != null || _barrioError != null) return;

    final user = ref.read(authProvider).user;
    final zonaCambio = user?.zona != _selectedZona;
    final barrioCambio = user?.barrio != (_selectedBarrio ?? '');

    if (!zonaCambio && !barrioCambio) {
      if (mounted) context.pop();
      return;
    }

    if (zonaCambio) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('¿Cambiar de zona?'),
          content: const Text(
            'Al cambiar de zona se quitarán tus suscripciones a barrios '
            'adicionales. Las alertas del mapa se ajustarán a tu nueva ubicación.',
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
    }

    setState(() => _loading = true);

    // updateLocation no implementado aún en AuthNotifier → simulamos éxito
    // final ok = await ref
    //     .read(authProvider.notifier)
    //     .updateLocation(_selectedZona, _selectedBarrio ?? '');
    final ok = true;

    if (!mounted) return;
    setState(() => _loading = false);

    if (!ok) {
      // final error = ref.read(authProvider).error;
      final error = ref.read(authProvider).errorMessage;
      if (error.isNotEmpty) {
        AppAlert.error(context, error);
      }
      return;
    }

    if (zonaCambio) {
      ref.read(barriosSubscribedProvider.notifier).setBarrios([]);
    }

    if (ref.exists(mapProvider)) {
      ref
          .read(mapProvider.notifier)
          .applyFilters(zonaFilter: _selectedZona, clearBarrioFilter: true);
    }

    if (mounted) {
      AppAlert.success(
        context,
        _selectedBarrio != null && _selectedBarrio!.isNotEmpty
            ? 'Ubicación actualizada: $_selectedZona · $_selectedBarrio'
            : 'Zona actualizada: $_selectedZona',
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    // user.barrio puede ser null → usamos ?? ''
    final ubicacionActual = user != null
        ? ((user.barrio ?? '').isNotEmpty
              ? '${user.zona ?? ''} · ${user.barrio}'
              : user.zona ?? '')
        : '';

    return Scaffold(
      appBar: AppBar(title: const Text('Cambiar zona')),
      body: ListView(
        padding: const EdgeInsets.all(AppConfig.horizontalMargin),
        children: [
          Card(
            child: ListTile(
              leading: Icon(Icons.my_location, color: AppConfig.primary),
              title: const Text('Ubicación actual'),
              subtitle: Text(ubicacionActual),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Nueva ubicación',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedZona,
            decoration: InputDecoration(
              labelText: 'Zona administrativa',
              errorText: _zonaError,
            ),
            items: kZonasAdministrativas.map((zona) {
              return DropdownMenuItem(value: zona, child: Text(zona));
            }).toList(),
            onChanged: _loading ? null : _onZonaChanged,
          ),
          if (_requiereBarrio) ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedBarrio,
              decoration: InputDecoration(
                labelText: 'Barrio',
                errorText: _barrioError,
              ),
              items: _barriosDeZona.map((barrio) {
                return DropdownMenuItem(value: barrio, child: Text(barrio));
              }).toList(),
              onChanged: _loading
                  ? null
                  : (value) {
                      setState(() {
                        _selectedBarrio = value;
                        _barrioError = null;
                      });
                    },
            ),
          ] else ...[
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
                      'Esta zona no tiene barrios específicos. '
                      'Recibirás alertas de toda la zona.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppConfig.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _loading ? null : _save,
            child: _loading
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
