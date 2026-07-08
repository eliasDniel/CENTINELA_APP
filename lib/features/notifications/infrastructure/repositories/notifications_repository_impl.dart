import '../../domain/constants/notification_window.dart';
import '../../domain/datasources/notifications_datasource.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../../notification_model.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._datasource);

  final NotificationsDatasource _datasource;

  @override
  Future<List<NotificationModel>> fetchMyNotifications({
    required String accessToken,
    int limit = 50,
    int offset = 0,
    int horas = kNotificationWindowHours,
  }) {
    return _datasource.fetchMyNotifications(
      accessToken: accessToken,
      limit: limit,
      offset: offset,
      horas: horas,
    );
  }

  @override
  Future<NotificationModel> markAsRead({
    required String accessToken,
    required String notificationId,
  }) {
    return _datasource.markAsRead(
      accessToken: accessToken,
      notificationId: notificationId,
    );
  }
}
