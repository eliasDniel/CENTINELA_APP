import 'package:centinela_milagro/features/auth/domain/entities/zona_entity.dart';

import 'package:dio/dio.dart';

import '../../../config/enviroment.dart';
import '../../domain/domain.dart';
import '../../presentation/providers/services/key_value_storage.dart';
import '../infrastructure.dart';

class AuthDataSourceImpl extends AuthDatasource {
  final KeyValueStorageService keyValueStorageService;
  final Dio _dio;

  AuthDataSourceImpl({required this.keyValueStorageService})
    : _dio = Dio(BaseOptions(baseUrl: Enviroment.apiUrl));

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final loginResponse = LoginResponse.fromJson(response.data);
      final user = UserMappers.fromLoginAndZona(loginResponse: loginResponse);
      return user;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<bool> register({
    required String email,
    required String password,
    required String alias,
    String? phone,
    required String zonaId,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'nombre': alias,
          'telefono': phone,
          'zonaId': zonaId,
        },
      );
      return response.statusCode == 201;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<UserEntity> checkStatus(String token) async {
    try {
      final refreshToken = await keyValueStorageService.getValue<String>(
        'refresh_token',
      );
      if (refreshToken == null) throw CustomError('No refresh token');

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      return UserMappers.fromCheckStatus(response.data);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<List<ZonaEntity>> getZonas() async {
    try {
      final response = await _dio.get('/zonas');
      final List<dynamic> data = response.data;
      return data.map((e) => UserMappers.fromResponseToEntity(e)).toList();
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Never _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      throw CustomError('Revisar conexión');
    }
    if (e.response?.statusCode == 401) {
      throw CustomError(
        e.response?.data['message'] ?? 'Credenciales inválidas',
      );
    }
    throw CustomError('Error inesperado');
  }
}
