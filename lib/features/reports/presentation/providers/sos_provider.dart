import 'package:centinela_milagro/core/location/user_location_provider.dart';
import 'package:centinela_milagro/core/utils/app_alert.dart';
import 'package:centinela_milagro/features/auth/presentation/providers/auth_provider.dart';
import 'package:centinela_milagro/features/map/domain/entities/map_alert_entity.dart';
import 'package:centinela_milagro/features/map/presentation/providers/last_sos_alert_provider.dart';
import 'package:centinela_milagro/features/map/presentation/providers/map_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/sos_loading_dialog.dart';
import 'reports_provider.dart';

Future<void> handleSosSent(BuildContext context, WidgetRef ref) async {
  final authState = ref.read(authProvider);
  if (authState.user == null) {
    AppAlert.error(context, 'Inicia sesión para enviar una alerta SOS');
    context.push('/auth');
    return;
  }

  final location = ref.read(userLocationProvider);

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const SosLoadingDialog(),
  );

  final errorMessage = await ref.read(reportsProvider.notifier).sendSosAlert(
    latitude: location.position.latitude,
    longitude: location.position.longitude,
  );

  if (!context.mounted) return;

  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  }

  if (errorMessage != null) {
    AppAlert.error(context, errorMessage);
    return;
  }

  final reports = ref.read(reportsProvider).reports;
  final latestReport = reports.isNotEmpty ? reports.first : null;
  if (latestReport != null && ref.exists(mapProvider)) {
    await ref.read(mapProvider.notifier).refreshAlerts();
    final alerts = ref.read(mapProvider).allAlerts;
    AlertEntity? mapAlert;
    for (final alert in alerts) {
      if (alert.reporteId == latestReport.id) {
        mapAlert = alert;
        break;
      }
    }
    if (mapAlert != null) {
      ref.read(lastSosAlertProvider.notifier).state = mapAlert;
    }
  }

  AppAlert.success(
    context,
    'Alerta SOS enviada. El equipo de seguridad fue notificado.',
  );
}
