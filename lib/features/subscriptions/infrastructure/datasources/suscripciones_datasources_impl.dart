import 'package:centinela_milagro/features/auth/domain/entities/zona_entity.dart';
import 'package:centinela_milagro/features/map/domain/entities/user_zona_entity.dart';
import 'package:centinela_milagro/features/map/infrastructure/models/zonas_by_user_response.dart';
import 'package:dio/dio.dart';

import '../../../auth/infrastructure/errors/auth_errors.dart';
import '../../../auth/presentation/providers/auth_session_keys.dart';
import '../../../auth/presentation/providers/services/key_value_storage.dart';
import '../../../config/enviroment.dart';
import '../../../reports/infrastructure/utils/report_api_error_message.dart';
import '../../domain/datasources/suscripciones_datasources.dart';
import '../mappers/suscripciones_mapper.dart';
import '../models/zona_catalog_response.dart';

class SuscripcionesDatasourcesImpl implements SuscripcionesDatasource {
  final KeyValueStorageService keyValueStorageService;
  final Dio _dio;

  SuscripcionesDatasourcesImpl({required this.keyValueStorageService})
    : _dio = Dio(BaseOptions(baseUrl: Enviroment.apiUrl));

  Future<Map<String, String>> _authHeaders() async {
    final token = await keyValueStorageService.getValue<String>(
      AuthSessionKeys.token,
    );
    if (token == null || token.isEmpty) return {};
    return {'Authorization': 'Bearer $token'};
  }

  Future<String> _currentUserId() async {
    final userId = await keyValueStorageService.getValue<String>(
      AuthSessionKeys.userUuid,
    );
    if (userId == null || userId.isEmpty) {
      throw CustomError('No se encontró la sesión del usuario');
    }
    return userId;
  }

  Never _handleDioError(DioException e) {
    final data = e.response?.data;
    throw CustomError(reportApiErrorMessage(data));
  }

  bool _isSuccessStatus(int? statusCode) {
    return statusCode != null && statusCode >= 200 && statusCode < 300;
  }

  @override
  Future<List<ZonaEntity>> getAllZonas() async {
    try {
      final response = await _dio.get('/zonas');
      final raw = response.data as List;
      return raw
          .map(
            (item) => SuscripcionesMapper.fromCatalogResponse(
              ZonaCatalogResponse.fromJson(item as Map<String, dynamic>),
            ),
          )
          .toList();
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<List<UserZonaEntity>> getMyZonas() async {
    try {
      final userId = await _currentUserId();
      final response = await _dio.get(
        '/zonas/usuarios/$userId',
        options: Options(headers: await _authHeaders()),
      );
      final raw = response.data as List;
      return raw
          .map(
            (item) => SuscripcionesMapper.fromUserZonaResponse(
              ZonasByUserResponse.fromJson(item as Map<String, dynamic>),
            ),
          )
          .toList();
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<bool> setPrincipalZona(String zonaId) async {
    try {
      final userId = await _currentUserId();
      final response = await _dio.post(
        '/zonas/usuarios/$userId/principal',
        data: {'zonaId': zonaId},
        options: Options(headers: await _authHeaders()),
      );
      return _isSuccessStatus(response.statusCode);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<bool> subscribeToZona(String zonaId) async {
    try {
      final userId = await _currentUserId();
      final response = await _dio.post(
        '/zonas/usuarios/$userId/suscripciones',
        data: {'zonaId': zonaId},
        options: Options(headers: await _authHeaders()),
      );
      return _isSuccessStatus(response.statusCode);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<bool> unsubscribeFromZona(String zonaId) async {
    try {
      final userId = await _currentUserId();
      final response = await _dio.delete(
        '/zonas/usuarios/$userId/suscripciones/$zonaId',
        options: Options(headers: await _authHeaders()),
      );
      return _isSuccessStatus(response.statusCode);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }
}
