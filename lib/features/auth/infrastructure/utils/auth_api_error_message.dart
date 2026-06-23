/// Normaliza y traduce errores del gateway / ms-auth (NestJS).
///
/// Soporta:
/// - `{ "message": "El Usuario ya existe", "statusCode": 409 }`
/// - `{ "message": ["password is not strong enough"], "error": "Bad Request" }`
String? extractAuthApiErrorMessage(dynamic data) {
  if (data == null) return null;

  if (data is String) {
    return _translateAuthApiMessage(data);
  }

  if (data is Map) {
    final fromMessage = _normalizeMessageValue(data['message']);
    if (fromMessage != null) return fromMessage;

    for (final key in ['error', 'detail']) {
      final fromKey = _normalizeMessageValue(data[key]);
      if (fromKey != null && fromKey != 'Bad Request') return fromKey;
    }
  }

  return null;
}

String? _normalizeMessageValue(dynamic value) {
  if (value == null) return null;

  if (value is String) {
    return _translateAuthApiMessage(value);
  }

  if (value is Iterable) {
    final parts = value
        .map((item) => _translateAuthApiMessage(item?.toString() ?? ''))
        .where((item) => item.isNotEmpty)
        .toList();
    if (parts.isEmpty) return null;
    return parts.join('\n');
  }

  return _translateAuthApiMessage(value.toString());
}

/// Mensajes ya en español (ms-auth) o validación del gateway en inglés.
String _translateAuthApiMessage(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return '';

  final exact = _authErrorTranslations[text];
  if (exact != null) return exact;

  final lower = text.toLowerCase();

  if (lower.contains('password is not strong enough') ||
      lower.contains('newpassword is not strong enough')) {
    return 'La contraseña debe incluir mayúsculas, minúsculas, números y símbolos';
  }

  if (lower.contains('email must be an email')) {
    return 'Ingresa un correo electrónico válido';
  }

  final minLength = RegExp(
    r'^(\w+) must be longer than or equal to (\d+) characters$',
    caseSensitive: false,
  ).firstMatch(text);
  if (minLength != null) {
    final field = _fieldLabel(minLength.group(1)!);
    final min = minLength.group(2)!;
    return '$field debe tener al menos $min caracteres';
  }

  final maxLength = RegExp(
    r'^(\w+) must be shorter than or equal to (\d+) characters$',
    caseSensitive: false,
  ).firstMatch(text);
  if (maxLength != null) {
    final field = _fieldLabel(maxLength.group(1)!);
    final max = maxLength.group(2)!;
    return '$field no puede superar $max caracteres';
  }

  final notEmpty = RegExp(
    r'^(\w+) should not be empty$',
    caseSensitive: false,
  ).firstMatch(text);
  if (notEmpty != null) {
    return '${_fieldLabel(notEmpty.group(1)!)} es obligatorio';
  }

  final mustBeString = RegExp(
    r'^(\w+) must be a string$',
    caseSensitive: false,
  ).firstMatch(text);
  if (mustBeString != null) {
    return '${_fieldLabel(mustBeString.group(1)!)} no es válido';
  }

  return text;
}

String _fieldLabel(String field) {
  switch (field.toLowerCase()) {
    case 'email':
      return 'El correo';
    case 'password':
    case 'newpassword':
      return 'La contraseña';
    case 'nombre':
      return 'El nombre';
    case 'telefono':
      return 'El teléfono';
    case 'token':
      return 'El token';
    case 'zonaId':
    case 'zonaid':
      return 'La zona';
    default:
      return 'El campo $field';
  }
}

const _authErrorTranslations = <String, String>{
  // ms-auth — ya en español (mejoras de redacción opcionales)
  'El Usuario ya existe': 'El usuario ya está registrado',
  'Credenciales inválidas': 'Credenciales inválidas',
  'La cuenta se encuentra desactivada. Contacte al administrador.':
      'La cuenta está desactivada. Contacta al administrador.',
  'Sesión inválida o expirada': 'Tu sesión expiró. Inicia sesión de nuevo',
  'Sesión no encontrada': 'No se encontró la sesión',
  'Token de verificación inválido o expirado':
      'El enlace de verificación no es válido o expiró',
  'Token inválido o expirado': 'El token no es válido o expiró',
  'Usuario no encontrado': 'Usuario no encontrado',
  'El usuario ya fue dado de baja': 'El usuario ya fue dado de baja',
  'No se pudo asignar la zona al usuario registrado':
      'No se pudo asignar la zona al registrarte',

  // ValidationPipe — inglés frecuente en auth
  'password is not strong enough':
      'La contraseña debe incluir mayúsculas, minúsculas, números y símbolos',
  'newPassword is not strong enough':
      'La contraseña debe incluir mayúsculas, minúsculas, números y símbolos',
  'email must be an email': 'Ingresa un correo electrónico válido',
  'email should not be empty': 'El correo es obligatorio',
  'email must be a string': 'El correo no es válido',
  'password must be longer than or equal to 8 characters':
      'La contraseña debe tener al menos 8 caracteres',
  'password must be shorter than or equal to 100 characters':
      'La contraseña no puede superar 100 caracteres',
  'newPassword must be longer than or equal to 8 characters':
      'La contraseña debe tener al menos 8 caracteres',
  'newPassword must be shorter than or equal to 100 characters':
      'La contraseña no puede superar 100 caracteres',
  'nombre must be shorter than or equal to 100 characters':
      'El nombre no puede superar 100 caracteres',
  'nombre should not be empty': 'El nombre es obligatorio',
  'nombre must be a string': 'El nombre no es válido',
  'token should not be empty': 'El token es obligatorio',
  'token must be a string': 'El token no es válido',

  // Gateway guards
  'Token no proporcionado': 'Debes iniciar sesión',
  'No tienes permisos para acceder a este recurso':
      'No tienes permiso para realizar esta acción',
};
