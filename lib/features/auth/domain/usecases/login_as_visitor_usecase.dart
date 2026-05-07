// RF-0302: Login as visitor use case
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginAsVisitorUseCase {
  final AuthRepository repository;

  LoginAsVisitorUseCase(this.repository);

  Future<UserEntity> call() {
    return repository.loginAsVisitor();
  }
}
