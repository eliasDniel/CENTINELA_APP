import 'package:centinela_milagro/features/map/domain/entities/user_zona_entity.dart';
import 'package:centinela_milagro/features/map/infrastructure/mappers/map_alert_mapper.dart';
import 'package:centinela_milagro/features/map/infrastructure/models/alerta_response.dart';
import 'package:centinela_milagro/features/reports/infrastructure/utils/report_api_error_message.dart';
import 'package:dio/dio.dart';

import '../../../auth/infrastructure/errors/auth_errors.dart';
import '../../../auth/presentation/providers/auth_session_keys.dart';
import '../../../auth/presentation/providers/services/key_value_storage.dart';
import '../../../config/enviroment.dart';
import '../../domain/datasources/map_datasource.dart';
import '../../domain/entities/map_alert_entity.dart';
import '../models/zonas_by_user_response.dart';

class MapDatasourceImpl implements MapDatasource {
  final KeyValueStorageService keyValueStorageService;
  final Dio _dio;

  MapDatasourceImpl({required this.keyValueStorageService})
    : _dio = Dio(BaseOptions(baseUrl: Enviroment.apiUrl));

  Future<void> _setAuthorizationHeader() async {
    final token = await keyValueStorageService.getValue<String>(
      AuthSessionKeys.token,
    );
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  @override
  Future<List<AlertEntity>> getActiveAlerts() async {
    try {
      await _setAuthorizationHeader();
      final response = await _dio.get('/alertas');
      final raw = response.data as List;
      final alertsResponse = raw
          .map((item) => AlertsResponse.fromJson(item as Map<String, dynamic>))
          .toList();
      return alertsResponse
          .map((alert) => MapAlertMapper.fromAlertsResponse(alert))
          .toList();
    } on DioException catch (e) {
      throw CustomError(reportApiErrorMessage(e.response?.data));
    } catch (_) {
      throw CustomError('Error al obtener las alertas');
    }
  }

  @override
  Future<List<AlertEntity>> getMapAlerts({int horas = 24}) async {
    try {
      await _setAuthorizationHeader();
      final response = await _dio.get(
        '/alertas/mapa',
        queryParameters: {'horas': horas},
      );
      final raw = response.data as List;
      final alertsResponse = raw
          .map((item) => AlertsResponse.fromJson(item as Map<String, dynamic>))
          .toList();
      return alertsResponse
          .map((alert) => MapAlertMapper.fromAlertsResponse(alert))
          .toList();
    } on DioException catch (e) {
      throw CustomError(reportApiErrorMessage(e.response?.data));
    } catch (_) {
      throw CustomError('Error al obtener las alertas del mapa');
    }
  }

  @override
  Future<List<AlertEntity>> getPublicMapAlerts({int horas = 24}) async {
    try {
      _dio.options.headers.remove('Authorization');
      final response = await _dio.get(
        '/alertas/mapa/public',
        queryParameters: {'horas': horas},
      );
      final raw = response.data as List;
      final alertsResponse = raw
          .map((item) => AlertsResponse.fromJson(item as Map<String, dynamic>))
          .toList();
      return alertsResponse
          .map((alert) => MapAlertMapper.fromAlertsResponse(alert))
          .toList();
    } on DioException catch (e) {
      throw CustomError(reportApiErrorMessage(e.response?.data));
    } catch (_) {
      throw CustomError('Error al obtener las alertas del mapa');
    }
  }

  @override
  Future<AlertEntity> getAlertById(String alertId) async {
    try {
      await _setAuthorizationHeader();
      final response = await _dio.get('/alertas/$alertId');
      final alertResponse = AlertsResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      return MapAlertMapper.fromAlertsResponse(alertResponse);
    } on DioException catch (e) {
      throw CustomError(reportApiErrorMessage(e.response?.data));
    } catch (_) {
      throw CustomError('Error al obtener la alerta');
    }
  }

  @override
  Future<List<UserZonaEntity>> getZonasByUser(String userId) async {
    try {
      await _setAuthorizationHeader();
      final response = await _dio.get('/zonas/usuarios/$userId');
      final raw = response.data as List;
      final zonasResponse = raw
          .map(
            (item) =>
                ZonasByUserResponse.fromJson(item as Map<String, dynamic>),
          )
          .toList();
      return zonasResponse
          .map((zona) => MapAlertMapper.fromUserZonaResponse(zona))
          .toList();
    } on DioException catch (e) {
      throw CustomError(reportApiErrorMessage(e.response?.data));
    } catch (_) {
      throw CustomError('Error al obtener las zonas');
    }
  }
}
