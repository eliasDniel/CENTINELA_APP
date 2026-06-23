import 'package:centinela_milagro/features/auth/infrastructure/errors/auth_errors.dart';
import 'package:centinela_milagro/features/auth/presentation/providers/auth_session_keys.dart';
import 'package:centinela_milagro/features/auth/presentation/providers/services/key_value_storage.dart';
import 'package:centinela_milagro/features/config/enviroment.dart';
import 'package:centinela_milagro/features/reports/domain/datasources/report_datasources.dart';
import 'package:centinela_milagro/features/reports/domain/entities/report_entity.dart';
import 'package:centinela_milagro/features/reports/infrastructure/mappers/report_mapper.dart';
import 'package:centinela_milagro/features/reports/infrastructure/models/reports_response.dart';
import 'package:centinela_milagro/features/reports/infrastructure/utils/report_api_error_message.dart';
import 'package:dio/dio.dart';

class ReportDatasourceImpl implements ReportsDatasources {
  final KeyValueStorageService keyValueStorageService;
  final Dio _dio;

  ReportDatasourceImpl({required this.keyValueStorageService})
    : _dio = Dio(BaseOptions(baseUrl: Enviroment.apiUrl));

  Future<Map<String, String>> _authHeaders() async {
    final token = await keyValueStorageService.getValue<String>(
      AuthSessionKeys.token,
    );
    if (token == null || token.isEmpty) return {};
    return {'Authorization': 'Bearer $token'};
  }

  Never _handleDioError(DioException e) {
    final data = e.response?.data;
    throw CustomError(reportApiErrorMessage(data));
  }

  @override
  Future<List<ReportEntity>> getHistoryReports() async {
    try {
      final response = await _dio.get(
        '/reportes',
        options: Options(headers: await _authHeaders()),
      );
      final raw = response.data;
      if (raw is! List) return [];

      return raw
          .whereType<Map<String, dynamic>>()
          .map(ReportsResponse.fromJson)
          .map(ReportMapper.fromReportsResponse)
          .toList();
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<ReportEntity> getReportById(String id) async {
    try {
      final response = await _dio.get(
        '/reportes/$id',
        options: Options(headers: await _authHeaders()),
      );
      final parsed = ReportsResponse.fromJson(response.data);
      return ReportMapper.fromReportsResponse(parsed);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<ReportEntity> sosAlert(
    String type,
    String description,
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await _dio.post(
        '/reportes',
        options: Options(headers: await _authHeaders()),
        data: {
          'tipo': 'PANICO',
          'descripcion': description,
          'latitud': latitude,
          'longitud': longitude,
        },
      );
      final parsed = ReportsResponse.fromJson(response.data);
      return ReportMapper.fromReportsResponse(parsed);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<ReportEntity> submitReport(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '/reportes',
        options: Options(headers: await _authHeaders()),
        data: data,
      );
      final parsed = ReportsResponse.fromJson(response.data);
      return ReportMapper.fromReportsResponse(parsed);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }
}
