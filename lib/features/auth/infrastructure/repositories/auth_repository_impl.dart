// RF-0301, RF-0302: Auth repository implementation
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(this.localDataSource);

  @override
  Future<UserEntity> login(String alias, String password) async {
    final model = await localDataSource.login(alias, password);
    return model.toEntity();
  }

  @override
  Future<UserEntity> register(String alias, String password, String barrio,
      {String? phone}) async {
    final model =
        await localDataSource.register(alias, password, barrio, phone: phone);
    return model.toEntity();
  }

  @override
  Future<UserEntity> loginAsVisitor() async {
    final model = await localDataSource.loginAsVisitor();
    return model.toEntity();
  }
}
