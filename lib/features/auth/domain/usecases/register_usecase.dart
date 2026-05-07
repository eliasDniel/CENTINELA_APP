// RF-0302: Register use case
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<UserEntity> call(String alias, String password, String barrio,
      {String? phone}) {
    // Validation: alias, password, and barrio cannot be empty
    if (alias.trim().isEmpty) {
      throw Exception('El alias no puede estar vacío');
    }
    if (password.trim().isEmpty) {
      throw Exception('La contraseña no puede estar vacía');
    }
    if (barrio.trim().isEmpty) {
      throw Exception('El barrio no puede estar vacío');
    }
    return repository.register(alias, password, barrio, phone: phone);
  }
}
