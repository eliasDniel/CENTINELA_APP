class UserEntity {
  final String uuid;
  final String email;
  final String rol;
  final String token;
  final String refreshToken; // <-- nuevo
  final String zonaId;

  UserEntity({
    required this.uuid,
    required this.email,
    required this.rol,
    required this.token,
    required this.refreshToken, // <-- nuevo
    required this.zonaId,
  });

  bool get tieneZona => zonaId.isNotEmpty;

  // ── Getters temporales ──────────────────────────────────────────────────
  // Permiten compilar toda la app mientras se implementan los campos reales.
  String get nombre => email.split('@').first;
  String? get barrio => null;
  String? get zona => null; // Antes era zonaNombre, pero ahora no está
  bool get tieneBarrio => false;
  bool get isVisitor => rol == 'visitante' || token.isEmpty;
  // ────────────────────────────────────────────────────────────────────────
}
