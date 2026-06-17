import '../domain.dart';
import '../entities/zona_entity.dart';

abstract class AuthRepository {
  // Inicia sesión
  Future<UserEntity> login(String email, String password);

  // Registra un usuario
  Future<bool> register({
    required String email,
    required String password,
    required String alias,
    String? phone,
    required String zonaId,
  });

  // Verifica el estado del usuario
  Future<UserEntity> checkStatus(String token);
  // Obtiene todas las zonas disponibles para asignar
  Future<List<ZonaEntity>> getZonas();
}
