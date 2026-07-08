import '../../notification_model.dart';

abstract class NotificationsRepository {
  Future<List<NotificationModel>> fetchMyNotifications({
    required String accessToken,
    int limit,
    int offset,
    int horas,
  });

  Future<NotificationModel> markAsRead({
    required String accessToken,
    required String notificationId,
  });
}
