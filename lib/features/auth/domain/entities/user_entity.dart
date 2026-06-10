// RF-0301: User entity for domain layer
class UserEntity {
  final String alias;
  final String uuid;
  final String zona;
  final String barrio;
  final String? phone;
  final bool isVisitor;

  UserEntity({
    required this.alias,
    required this.uuid,
    required this.zona,
    required this.barrio,
    this.phone,
    required this.isVisitor,
  });

  bool get tieneBarrio => barrio.isNotEmpty;
}
