part of 'notifications_bloc.dart';

sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class NotificationsChangeStatus extends NotificationsEvent {
  const NotificationsChangeStatus(this.status);

  final AuthorizationStatus status;

  @override
  List<Object?> get props => [status];
}

class NotificationsSaveToken extends NotificationsEvent {
  const NotificationsSaveToken(this.token);

  final String token;

  @override
  List<Object?> get props => [token];
}

class NotificationsReceived extends NotificationsEvent {
  const NotificationsReceived(this.notification);

  final NotificationModel notification;

  @override
  List<Object?> get props => [notification];
}

class NotificationsLoadHistory extends NotificationsEvent {
  const NotificationsLoadHistory(this.accessToken);

  final String accessToken;

  @override
  List<Object?> get props => [accessToken];
}

class NotificationsMarkAsRead extends NotificationsEvent {
  const NotificationsMarkAsRead({
    required this.accessToken,
    required this.notificationId,
  });

  final String accessToken;
  final String notificationId;

  @override
  List<Object?> get props => [accessToken, notificationId];
}
