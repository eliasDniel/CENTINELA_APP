import 'package:centinela_milagro/features/auth/domain/entities/zona_entity.dart';
import 'package:centinela_milagro/features/auth/infrastructure/models/check_status.dart';
import 'package:centinela_milagro/features/auth/infrastructure/utils/auth_refresh_lock.dart';

import 'package:dio/dio.dart';

import '../../../config/enviroment.dart';
import '../../domain/domain.dart';
import '../utils/auth_api_error_message.dart';
import '../infrastructure.dart';

class AuthDataSourceImpl extends AuthDatasource {
  final Dio _dio;

  AuthDataSourceImpl()
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
        message:
            data['message']?.toString() ??
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
        data: {'token': token.trim(), 'newPassword': newPassword},
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      return data['message']?.toString() ??
          'Contraseña actualizada correctamente';
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<String> changePassword({
    required String accessToken,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      return data['message']?.toString() ??
          'Contraseña actualizada correctamente';
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<String> deleteAccount(String accessToken) async {
    try {
      final response = await _dio.delete(
        '/auth/me',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      return data['message']?.toString() ??
          'Cuenta y datos personales eliminados correctamente';
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Never _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw CustomError('Revisar conexión');
    }

    final backendMessage = _extractErrorMessage(e);
    if (backendMessage != null) {
      throw CustomError(backendMessage);
    }

    switch (e.response?.statusCode) {
      case 401:
        throw CustomError('Credenciales inválidas');
      case 400:
        throw CustomError('Solicitud inválida');
      default:
        throw CustomError('Error inesperado');
    }
  }

  String? _extractErrorMessage(DioException e) {
    return extractAuthApiErrorMessage(e.response?.data);
  }
}
