// RF-0301: Login use case
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserEntity> call(String alias, String password) {
    // Validation: alias and password cannot be empty
    if (alias.trim().isEmpty) {
      throw Exception('El alias no puede estar vacío');
    }
    if (password.trim().isEmpty) {
      throw Exception('La contraseña no puede estar vacía');
    }
    return repository.login(alias, password);
  }
}
