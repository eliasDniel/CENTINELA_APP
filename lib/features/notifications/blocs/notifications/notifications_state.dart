part of 'notifications_bloc.dart';

class NotificationsState extends Equatable {
  const NotificationsState({
    this.status = AuthorizationStatus.notDetermined,
    this.notifications = const [],
    this.token,
    this.isLoadingHistory = false,
    this.historyError,
  });

  final AuthorizationStatus status;
  final List<NotificationModel> notifications;
  final String? token;
  final bool isLoadingHistory;
  final String? historyError;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationsState copyWith({
    AuthorizationStatus? status,
    List<NotificationModel>? notifications,
    String? token,
    bool? isLoadingHistory,
    String? historyError,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      token: token ?? this.token,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      historyError: historyError,
    );
  }

  @override
  List<Object?> get props => [
        status,
        notifications,
        token,
        isLoadingHistory,
        historyError,
        unreadCount,
      ];
}
