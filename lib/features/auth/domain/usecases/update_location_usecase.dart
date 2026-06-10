import '../../../subscriptions/domain/constants/zonas_administrativas.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class UpdateLocationUseCase {
  final AuthRepository repository;

  UpdateLocationUseCase(this.repository);

  Future<UserEntity> call(String alias, String zona, String barrio) {
    if (zona.trim().isEmpty) {
      throw Exception('La zona no puede estar vacía');
    }
    if (zonaTieneBarrios(zona) && barrio.trim().isEmpty) {
      throw Exception('Debes seleccionar un barrio');
    }
    return repository.updateLocation(alias, zona, barrio);
  }
}
