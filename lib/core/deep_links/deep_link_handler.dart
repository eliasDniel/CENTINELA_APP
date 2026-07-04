import 'package:go_router/go_router.dart';

/// Rutas de deep link soportadas (esquema `centinela://` o web `/reset-password`).
class DeepLinkHandler {
  static const resetPasswordPath = 'reset-password';
  static Uri? pendingUri;

  /// Convierte un URI entrante en ruta interna de GoRouter, o null si no aplica.
  static String? toAppRoute(Uri uri) {
    if (!_isResetPasswordLink(uri)) return null;

    final token = uri.queryParameters['token']?.trim();
    if (token == null || token.isEmpty) return '/reset-password';

    return '/reset-password?token=${Uri.encodeComponent(token)}';
  }

  static bool _isResetPasswordLink(Uri uri) {
    if (uri.scheme == 'centinela') {
      if (uri.host == resetPasswordPath) return true;
      if (uri.path.toLowerCase().contains(resetPasswordPath)) return true;
      return false;
    }

    final path = uri.path.toLowerCase();
    return path == '/reset-password' ||
        path.endsWith('/reset-password') ||
        uri.host == resetPasswordPath;
  }

  static void navigate(GoRouter router, Uri uri) {
    final route = toAppRoute(uri);
    if (route == null) return;

    pendingUri = null;
    router.go(route);
  }

  static void remember(Uri uri) {
    if (toAppRoute(uri) != null) {
      pendingUri = uri;
    }
  }

  static void flushPending(GoRouter router) {
    final uri = pendingUri;
    if (uri == null) return;
    navigate(router, uri);
  }
}
