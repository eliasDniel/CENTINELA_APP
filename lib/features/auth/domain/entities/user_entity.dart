// RF-0301: User entity for domain layer
class UserEntity {
  final String alias;
  final String uuid;
  final String barrio;
  final String? phone;
  final bool isVisitor;

  UserEntity({
    required this.alias,
    required this.uuid,
    required this.barrio,
    this.phone,
    required this.isVisitor,
  });
}
