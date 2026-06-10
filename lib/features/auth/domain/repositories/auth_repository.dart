// RF-0301, RF-0302: Auth repository interface
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String alias, String password);
  Future<UserEntity> register(
    String alias,
    String password,
    String zona,
    String barrio, {
    String? phone,
  });
  Future<UserEntity> loginAsVisitor();
  Future<UserEntity> updateLocation(String alias, String zona, String barrio);
}
