import 'package:centinela_milagro/features/auth/domain/entities/zona_entity.dart';

import '../domain.dart';

abstract class AuthDatasource {
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

  // Cierra sesión
  Future<bool> logout(String token);

  // Obtiene todas las zonas disponibles para asignar
  Future<List<ZonaEntity>> getZonas();

  Future<PasswordRecoveryResult> forgotPassword(String email);

  Future<String> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<String> changePassword({
    required String accessToken,
    required String currentPassword,
    required String newPassword,
  });

  /// Elimina la cuenta autenticada y sus datos (LOPDP Art. 19).
  Future<String> deleteAccount(String accessToken);

  Future<void> disablePushNotifications({
    required String accessToken,
    required String fcmToken,
  });
  Future<void> registerPushNotifications({
    required String accessToken,
    required String fcmToken,
  });
}
