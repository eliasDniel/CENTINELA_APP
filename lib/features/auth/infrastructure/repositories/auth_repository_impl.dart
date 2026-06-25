import 'package:centinela_milagro/features/auth/domain/entities/zona_entity.dart';

import '../../domain/domain.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthDatasource dataSources;

  AuthRepositoryImpl({required this.dataSources});

  @override
  Future<UserEntity> checkStatus(String token) {
    return dataSources.checkStatus(token);
  }

  @override
  Future<UserEntity> login(String email, String password) {
    return dataSources.login(email, password);
  }

  @override
  Future<bool> register({
    required String email,
    required String password,
    required String alias,
    String? phone,
    required String zonaId,
  }) {
    return dataSources.register(
      email: email,
      password: password,
      alias: alias,
      phone: phone,
      zonaId: zonaId,
    );
  }

    
  @override
  Future<bool> logout(String token) {
    return dataSources.logout(token);
  }

  @override
  Future<List<ZonaEntity>> getZonas() {
    return dataSources.getZonas();
  }

  @override
  Future<PasswordRecoveryResult> forgotPassword(String email) {
    return dataSources.forgotPassword(email);
  }

  @override
  Future<String> resetPassword({
    required String token,
    required String newPassword,
  }) {
    return dataSources.resetPassword(token: token, newPassword: newPassword);
  }

  @override
  Future<String> deleteAccount(String accessToken) {
    return dataSources.deleteAccount(accessToken);
  }
}
