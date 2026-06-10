// RF-0302: Register use case
import '../../../subscriptions/domain/constants/zonas_administrativas.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<UserEntity> call(
    String alias,
    String password,
    String zona,
    String barrio, {
    String? phone,
  }) {
    if (alias.trim().isEmpty) {
      throw Exception('El alias no puede estar vacío');
    }
    if (password.trim().isEmpty) {
      throw Exception('La contraseña no puede estar vacía');
    }
    if (zona.trim().isEmpty) {
      throw Exception('La zona no puede estar vacía');
    }
    if (zonaTieneBarrios(zona) && barrio.trim().isEmpty) {
      throw Exception('Debes seleccionar un barrio');
    }
    return repository.register(alias, password, zona, barrio, phone: phone);
  }
}
