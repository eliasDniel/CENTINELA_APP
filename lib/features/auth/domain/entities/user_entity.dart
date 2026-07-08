class UserEntity {
  final String uuid;
  final String alias;
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
    required this.alias,
  });

  bool get tieneZona => zonaId.isNotEmpty;

  String get nombre => alias;

  String? get zona => zonaNombre;

  String? get barrio => null;

  bool get tieneBarrio => false;

  bool get isVisitor => rol == 'visitante';

  UserEntity copyWith({
    String? uuid,
    String? email,
    String? rol,
    String? token,
    String? refreshToken,
    String? zonaId,
    String? zonaNombre,
    String? alias,
  }) {
    return UserEntity(
      uuid: uuid ?? this.uuid,
      email: email ?? this.email,
      rol: rol ?? this.rol,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      zonaId: zonaId ?? this.zonaId,
      zonaNombre: zonaNombre ?? this.zonaNombre,
      alias: alias ?? this.alias,
    );
  }
}
