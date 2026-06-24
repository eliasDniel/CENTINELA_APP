import 'package:centinela_milagro/features/auth/infrastructure/errors/auth_errors.dart';
import 'package:centinela_milagro/features/auth/presentation/providers/auth_session_keys.dart';
import 'package:centinela_milagro/features/auth/presentation/providers/services/key_value_storage.dart';
import 'package:centinela_milagro/features/map/infrastructure/mappers/map_alert_mapper.dart';
import 'package:centinela_milagro/features/map/infrastructure/models/alerta_response.dart';
import 'package:centinela_milagro/features/reports/infrastructure/utils/report_api_error_message.dart';
import 'package:dio/dio.dart';

import '../../../config/enviroment.dart';
import '../../domain/datasources/map_datasource.dart';
import '../../domain/entities/map_alert_entity.dart';

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
      final raw = response.data;
      final alertsResponse = raw.map((item) => AlertsResponse.fromJson(item)).toList();
      final alerts = alertsResponse.map((alert) => MapAlertMapper.fromAlertsResponse(alert)).toList();
      return alerts;
    } on DioException catch (e) {
      throw CustomError(reportApiErrorMessage(e.response?.data));
    } catch (_) {
      throw CustomError('Error al obtener las alertas');
    }
  }
  
  @override
  Future<Map<String, dynamic>> getAlertById(String alertId) async{
    try {
      await _setAuthorizationHeader();
      final response = await _dio.get('/alertas/$alertId');
      return response.data;
    } on DioException catch (e) {
      throw CustomError(reportApiErrorMessage(e.response?.data));
    } catch (_) {
      throw CustomError('Error al obtener la alerta');
    }
  }
  
  @override
  Future<List<Map<String, dynamic>>> getZonasByUser(String userId, String zonaId)async {
    try {
      await _setAuthorizationHeader();
      final response = await _dio.get('/zonas/usuario/$userId/$zonaId');
      return response.data;
    } on DioException catch (e) {
      throw CustomError(reportApiErrorMessage(e.response?.data));
    } catch (_) {
      throw CustomError('Error al obtener las zonas');
    }
  }
}
