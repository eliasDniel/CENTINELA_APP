class UserEntity {
  final String uuid;
  final String email;
  final String rol;
  final String token;
  final String refreshToken;
  final String zonaId;
  final String? zonaNombre;

  UserEntity({
    required this.uuid,
    required this.email,
    required this.rol,
    required this.token,
    required this.refreshToken,
    required this.zonaId,
    this.zonaNombre,
  });

  bool get tieneZona => zonaId.isNotEmpty;

  String get nombre => email.split('@').first;

  String? get zona => zonaNombre;

  String? get barrio => null;

  bool get tieneBarrio => false;

  bool get isVisitor => rol == 'visitante' || token.isEmpty;

  UserEntity copyWith({
    String? uuid,
    String? email,
    String? rol,
    String? token,
    String? refreshToken,
    String? zonaId,
    String? zonaNombre,
  }) {
    return UserEntity(
      uuid: uuid ?? this.uuid,
      email: email ?? this.email,
      rol: rol ?? this.rol,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      zonaId: zonaId ?? this.zonaId,
      zonaNombre: zonaNombre ?? this.zonaNombre,
    );
  }
}
