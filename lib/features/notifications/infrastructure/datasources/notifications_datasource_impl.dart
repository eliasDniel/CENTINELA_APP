import 'package:dio/dio.dart';

import '../../../config/enviroment.dart';
import '../../domain/datasources/notifications_datasource.dart';
import '../../notification_model.dart';

class NotificationsDatasourceImpl implements NotificationsDatasource {
  NotificationsDatasourceImpl({Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: Enviroment.apiUrl));

  final Dio _dio;

  Options _authOptions(String accessToken) => Options(
        headers: {'Authorization': 'Bearer $accessToken'},
      );

  @override
  Future<List<NotificationModel>> fetchMyNotifications({
    required String accessToken,
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _dio.get(
      '/notificaciones/mias',
      queryParameters: {'limit': limit, 'offset': offset},
      options: _authOptions(accessToken),
    );

    final data = response.data;
    if (data is! List) return [];

    return data
        .map((item) => NotificationModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ))
        .toList();
  }

  @override
  Future<NotificationModel> markAsRead({
    required String accessToken,
    required String notificationId,
  }) async {
    final response = await _dio.patch(
      '/notificaciones/mias/$notificationId/leida',
      options: _authOptions(accessToken),
    );

    return NotificationModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }
}
