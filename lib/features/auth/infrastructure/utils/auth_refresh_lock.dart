import '../../domain/domain.dart';

/// Evita dos llamadas simultáneas a /auth/refresh (hot reload, providers duplicados).
class AuthRefreshLock {
  static Future<UserEntity>? _inFlight;

  static Future<UserEntity> run(Future<UserEntity> Function() refresh) {
    final pending = _inFlight;
    if (pending != null) return pending;

    final future = refresh();
    _inFlight = future;
    return future.whenComplete(() => _inFlight = null);
  }
}
