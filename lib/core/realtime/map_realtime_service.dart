import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/map/presentation/providers/map_provider.dart';
import 'realtime_url.dart';

String? _alertIdFromPayload(dynamic data) {
  if (data is! Map) return null;
  final id = data['id'];
  if (id == null) return null;
  final text = id.toString();
  return text.isEmpty ? null : text;
}

class MapRealtimeService {
  MapRealtimeService(this._ref);

  final Ref _ref;
  io.Socket? _socket;
  String? _connectedToken;

  Future<void> syncAuth(AuthState auth) async {
    if (auth.authStatus != AuthStatus.authenticated ||
        auth.user == null ||
        auth.user!.isVisitor) {
      _disconnect();
      return;
    }

    final token = await _ref.read(authProvider.notifier).resolveAccessToken();
    if (token == null || token.isEmpty) {
      _disconnect();
      return;
    }

    if (_socket != null && _connectedToken == token && _socket!.connected) {
      return;
    }

    _connect(token);
  }

  void _connect(String token) {
    _disconnect();
    _connectedToken = token;

    final socket = io.io(
      buildRealtimeSocketUrl(),
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .setReconnectionAttempts(12)
          .setAuth({'token': token})
          .build(),
    );

    socket.onConnect((_) {});
    socket.on('alerta.created', _onAlertCreated);
    socket.on('alerta.updated', _onAlertUpdated);
    socket.onDisconnect((_) {});
    socket.connect();

    _socket = socket;
  }

  void _onAlertCreated(dynamic data) {
    final alertId = _alertIdFromPayload(data);
    if (alertId == null) return;
    _ref.read(mapProvider.notifier).onRealtimeAlertEvent(alertId);
  }

  void _onAlertUpdated(dynamic data) {
    final alertId = _alertIdFromPayload(data);
    if (alertId == null) return;
    _ref.read(mapProvider.notifier).onRealtimeAlertEvent(alertId);
  }

  void _disconnect() {
    _socket?.dispose();
    _socket = null;
    _connectedToken = null;
  }

  void dispose() => _disconnect();
}

final mapRealtimeServiceProvider = Provider<MapRealtimeService>((ref) {
  final service = MapRealtimeService(ref);
  ref.onDispose(service.dispose);

  ref.listen<AuthState>(authProvider, (previous, next) {
    service.syncAuth(next);
  }, fireImmediately: true);

  return service;
});

/// Mantiene viva la conexión WebSocket del mapa.
class MapRealtimeSync extends ConsumerWidget {
  const MapRealtimeSync({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(mapRealtimeServiceProvider);
    return child;
  }
}
