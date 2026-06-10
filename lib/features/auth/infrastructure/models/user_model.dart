// RF-0301, RF-0302: User model for infrastructure layer
import '../../domain/entities/user_entity.dart';

class UserModel {
  final String alias;
  final String uuid;
  final String zona;
  final String barrio;
  final String? phone;
  final bool isVisitor;

  UserModel({
    required this.alias,
    required this.uuid,
    required this.zona,
    required this.barrio,
    this.phone,
    required this.isVisitor,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      alias: json['alias'] as String,
      uuid: json['uuid'] as String,
      zona: json['zona'] as String? ?? 'Milagro',
      barrio: json['barrio'] as String? ?? '',
      phone: json['phone'] as String?,
      isVisitor: json['isVisitor'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alias': alias,
      'uuid': uuid,
      'zona': zona,
      'barrio': barrio,
      'phone': phone,
      'isVisitor': isVisitor,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      alias: alias,
      uuid: uuid,
      zona: zona,
      barrio: barrio,
      phone: phone,
      isVisitor: isVisitor,
    );
  }

  static UserModel fromEntity(UserEntity entity) {
    return UserModel(
      alias: entity.alias,
      uuid: entity.uuid,
      zona: entity.zona,
      barrio: entity.barrio,
      phone: entity.phone,
      isVisitor: entity.isVisitor,
    );
  }
}
