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
  Future<List<ZonaEntity>> getZonas() {
    return dataSources.getZonas();
  }
}
