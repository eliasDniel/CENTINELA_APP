// RF-0304, RF-0305: envío simulado de SOS
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../map/domain/entities/map_alert_entity.dart';
import '../../../map/presentation/providers/map_provider.dart';
import '../../../../core/location/user_location_provider.dart';
import 'reports_provider.dart';

/// Tras enviar SOS, el mapa centra esta alerta al abrirse.
final lastSosAlertProvider = StateProvider<MapAlertEntity?>((ref) => null);

/// Índice de pestaña del shell según la ruta (`/home/0` … `/home/3`).
int shellTabIndexFromContext(BuildContext context) {
  final page = GoRouterState.of(context).pathParameters['page'];
  return int.tryParse(page ?? '0') ?? 0;
}

bool isMapTabActive(BuildContext context) => shellTabIndexFromContext(context) == 1;

/// Enfoca la SOS en el mapa sin navegar (si ya estás en la pestaña mapa).
void focusSosOnMapIfReady(WidgetRef ref) {
  final pending = ref.read(lastSosAlertProvider);
  if (pending == null || !ref.exists(mapProvider)) return;
  ref.read(mapProvider.notifier).focusPendingSos(pending);
  ref.read(lastSosAlertProvider.notifier).state = null;
}

/// Abre el mapa solo si hace falta; si ya estás ahí, solo enfoca la alerta.
void openMapForSos(BuildContext context, WidgetRef ref) {
  if (isMapTabActive(context)) {
    focusSosOnMapIfReady(ref);
    return;
  }
  context.go('/home/1');
}

/// Simula envío de SOS y registra la alerta en el mapa.
Future<MapAlertEntity> sendSosAlert(
  WidgetRef ref, {
  bool offline = false,
}) async {
  await Future.delayed(
    Duration(milliseconds: offline ? 400 : 900),
  );

  final auth = ref.read(authProvider);
  final location = ref.read(userLocationProvider);
  final zona = auth.user?.zona ?? 'Milagro';
  final barrio = auth.user?.barrio ?? '';
  final pseudonym = auth.user?.uuid;

  final repository = ref.read(mapRepositoryProvider);
  final alert = repository.publishSosAlert(
    lat: location.position.latitude,
    lng: location.position.longitude,
    zona: zona,
    barrio: barrio,
    pseudonym: pseudonym,
    timestamp: DateTime.now(),
  );

  ref.read(lastSosAlertProvider.notifier).state = alert;

  if (ref.exists(mapProvider)) {
    ref.read(mapProvider.notifier).prependAlert(alert);
  }

  ref.invalidate(recentReportsProvider);

  return alert;
}
