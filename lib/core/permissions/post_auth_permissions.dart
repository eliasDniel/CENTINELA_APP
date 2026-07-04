import 'package:centinela_milagro/core/location/user_location_provider.dart';
import 'package:centinela_milagro/core/location/user_location_service.dart';
import 'package:centinela_milagro/core/notifications/notification_preferences.dart';
import 'package:centinela_milagro/features/auth/presentation/providers/auth_provider.dart';
import 'package:centinela_milagro/features/notifications/blocs/notifications/notifications_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tras autenticarse (login o sesión restaurada), pide permisos en orden:
/// 1. Notificaciones push (si están habilitadas en ajustes de la app)
/// 2. Ubicación GPS
class PostAuthPermissionsListener extends ConsumerStatefulWidget {
  const PostAuthPermissionsListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PostAuthPermissionsListener> createState() =>
      _PostAuthPermissionsListenerState();
}

class _PostAuthPermissionsListenerState
    extends ConsumerState<PostAuthPermissionsListener> {
  bool _requestedForCurrentSession = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      if (next.authStatus != AuthStatus.authenticated) {
        _requestedForCurrentSession = false;
        return;
      }

      if (previous?.authStatus == AuthStatus.authenticated) return;
      if (_requestedForCurrentSession) return;

      _requestedForCurrentSession = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _requestInOrder();
      });
    });

    return widget.child;
  }

  Future<void> _requestInOrder() async {
    if (ref.read(authProvider).authStatus != AuthStatus.authenticated) return;

    if (NotificationPreferences.enabled) {
      await context.read<NotificationsBloc>().requestPermissions();
    }

    if (!mounted) return;
    if (ref.read(authProvider).authStatus != AuthStatus.authenticated) return;

    await UserLocationService.ensurePermission();

    if (!mounted) return;
    await ref.read(userLocationProvider.notifier).refresh();
  }
}
