import 'dart:async';

import 'package:centinela_milagro/core/location/user_location_provider.dart';
import 'package:centinela_milagro/core/utils/app_alert.dart';
import 'package:centinela_milagro/features/auth/presentation/providers/auth_provider.dart';
import 'package:centinela_milagro/features/map/presentation/providers/pending_sos_report_provider.dart';
import 'package:centinela_milagro/features/reports/domain/entities/report_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/sos_loading_dialog.dart';
import 'reports_provider.dart';

Future<void> handleSosSent(BuildContext context) async {
  // ProviderContainer survives widget unmounts (e.g. tab switches during async work).
  final container = ProviderScope.containerOf(context);
  final rootNavigator = Navigator.of(context, rootNavigator: true);

  final authState = container.read(authProvider);
  if (authState.user == null) {
    AppAlert.error(context, 'Inicia sesión para enviar una alerta SOS');
    context.push('/auth');
    return;
  }

  final location = container.read(userLocationProvider);

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (_) => const SosLoadingDialog(),
  );

  final errorMessage =
      await container.read(reportsProvider.notifier).sendSosAlert(
            latitude: location.position.latitude,
            longitude: location.position.longitude,
          );

  if (rootNavigator.mounted && rootNavigator.canPop()) {
    rootNavigator.pop();
  }

  if (errorMessage != null) {
    if (context.mounted) {
      AppAlert.error(context, errorMessage);
    }
    return;
  }

  if (context.mounted) {
    AppAlert.success(
      context,
      'Alerta SOS enviada. El equipo de seguridad fue notificado.',
    );
  }

  final reports = container.read(reportsProvider).reports;
  final latestReport = reports.isNotEmpty ? reports.first : null;
  if (latestReport != null) {
    unawaited(_linkLatestSosToMap(container, latestReport));
  }
}

Future<void> _linkLatestSosToMap(
  ProviderContainer container,
  ReportEntity latestReport,
) async {
  container.read(pendingSosReportIdProvider.notifier).state = latestReport.id;
}
