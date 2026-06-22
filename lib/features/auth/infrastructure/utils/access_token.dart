import 'dart:convert';

/// Valida si el JWT de acceso sigue vigente (con margen de 1 min).
bool isAccessTokenValid(
  String token, {
  Duration leeway = const Duration(minutes: 1),
}) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return false;

    final payload = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    );
    if (payload is! Map<String, dynamic>) return false;

    final exp = payload['exp'];
    if (exp is! num) return false;

    final expiresAt = DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
    return DateTime.now().isBefore(expiresAt.subtract(leeway));
  } catch (_) {
    return false;
  }
}
