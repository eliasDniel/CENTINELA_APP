import 'package:centinela_milagro/features/auth/domain/entities/zona_entity.dart';
import 'package:centinela_milagro/features/auth/infrastructure/models/check_status.dart';
import 'package:centinela_milagro/features/auth/infrastructure/utils/auth_refresh_lock.dart';

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
      return response.statusCode == 201 || response.statusCode == 200;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<UserEntity> checkStatus(String token) {
    return AuthRefreshLock.run(() => _refreshSession(token));
  }

  Future<UserEntity> _refreshSession(String token) async {
    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': token},
      );
      return UserMappers.fromCheckStatus(
        CheckStatusResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        ),
      );
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<bool> logout(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/auth/logout',
        data: {'refreshToken': refreshToken},
      );
      if (response.statusCode == 200) {
        await keyValueStorageService.removeKey('token');
        await keyValueStorageService.removeKey('refresh_token');
        return true;
      }
      throw CustomError(response.data['message']);
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

  @override
  Future<PasswordRecoveryResult> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        '/auth/forgot-password',
        data: {'email': email.trim()},
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      return PasswordRecoveryResult(
        message: data['message']?.toString() ??
            'Si el correo existe, se ha enviado un token de recuperación.',
        resetToken: data['tokenResetPwd']?.toString(),
      );
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<String> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/reset-password',
        data: {
          'token': token.trim(),
          'newPassword': newPassword,
        },
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      return data['message']?.toString() ?? 'Contraseña actualizada correctamente';
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
    if (e.response?.data is Map && e.response?.data['message'] != null) {
      throw CustomError(e.response!.data['message'].toString());
    }
    throw CustomError('Error inesperado');
  }
}
