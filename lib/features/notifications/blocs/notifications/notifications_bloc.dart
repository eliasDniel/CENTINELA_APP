import 'dart:io';

import 'package:centinela_milagro/core/notifications/fcm_token_registry.dart';
import 'package:centinela_milagro/core/notifications/notification_preferences.dart';
import 'package:centinela_milagro/firebase_options.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/constants/notification_window.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../../infrastructure/datasources/notifications_datasource_impl.dart';
import '../../infrastructure/local_notification_service.dart';
import '../../infrastructure/repositories/notifications_repository_impl.dart';
import '../../notification_model.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  final pushEnabled =
      prefs.getBool(NotificationPreferences.storageKey) ?? true;
  if (!pushEnabled) return;

  if (message.notification != null) return;

  if (message.data.isEmpty) return;

  await LocalNotificationService.instance.initialize();
  await LocalNotificationService.instance.show(
    id: message.data['id']?.toString() ??
        message.messageId ??
        DateTime.now().millisecondsSinceEpoch.toString(),
    title: message.data['title']?.toString() ?? 'Centinela',
    body: message.data['body']?.toString() ?? '',
  );
}

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc({NotificationsRepository? repository})
      : _repository = repository ??
            NotificationsRepositoryImpl(NotificationsDatasourceImpl()),
        super(const NotificationsState()) {
    on<NotificationsChangeStatus>(_onStatusChanged);
    on<NotificationsSaveToken>(_onSaveToken);
    on<NotificationsReceived>(_onReceived);
    on<NotificationsLoadHistory>(_onLoadHistory);
    on<NotificationsMarkAsRead>(_onMarkAsRead);
    _bootstrap();
  }

  final NotificationsRepository _repository;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initializeFCM() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await LocalNotificationService.instance.initialize();

    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        FcmTokenRegistry.update(token);
      }
    }
  }

  Future<void> _bootstrap() async {
    final settings = await _messaging.getNotificationSettings();
    add(NotificationsChangeStatus(settings.authorizationStatus));

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    _messaging.onTokenRefresh.listen((token) {
      if (!NotificationPreferences.enabled) return;
      FcmTokenRegistry.update(token);
      add(NotificationsSaveToken(token));
    });

    if (NotificationPreferences.enabled &&
        (settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional)) {
      await refreshToken();
    }
  }

  Future<void> refreshToken() async {
    if (!NotificationPreferences.enabled) return;
    final token = await _messaging.getToken();
    if (token == null || token.isEmpty) return;
    FcmTokenRegistry.update(token);
    add(NotificationsSaveToken(token));
  }

  Future<void> requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    add(NotificationsChangeStatus(settings.authorizationStatus));
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      await refreshToken();
    }
  }

  void handleRemoteMessage(RemoteMessage message) {
    if (!NotificationPreferences.enabled) return;
    final notification = _mapRemoteMessage(message);
    if (notification == null) return;
    add(NotificationsReceived(notification));
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (!NotificationPreferences.enabled) return;
    final notification = _mapRemoteMessage(message);
    if (notification == null) return;

    // App abierta: solo lista + contador, sin banner del sistema.
    add(NotificationsReceived(notification));
  }

  NotificationModel? _mapRemoteMessage(RemoteMessage message) {
    if (message.data.isNotEmpty && message.data['id'] != null) {
      return NotificationModel.fromPushData(message.data);
    }

    final push = message.notification;
    if (push == null) return null;

    return NotificationModel(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: push.title ?? '',
      body: push.body ?? '',
      barrio: 'Sin zona',
      type: NotificationType.alertaSeguridad,
      timestamp: message.sentTime ?? DateTime.now(),
      alertaId: message.data['alertaId']?.toString(),
    );
  }

  void _onStatusChanged(
    NotificationsChangeStatus event,
    Emitter<NotificationsState> emit,
  ) {
    emit(state.copyWith(status: event.status));
  }

  void _onSaveToken(
    NotificationsSaveToken event,
    Emitter<NotificationsState> emit,
  ) {
    emit(state.copyWith(token: event.token));
  }

  void _onReceived(
    NotificationsReceived event,
    Emitter<NotificationsState> emit,
  ) {
    if (!isNotificationWithinWindow(event.notification.timestamp)) return;

    final exists = state.notifications.any((n) => n.id == event.notification.id);
    if (exists) return;

    emit(
      state.copyWith(
        notifications: [event.notification, ...state.notifications],
      ),
    );
  }

  Future<void> _onLoadHistory(
    NotificationsLoadHistory event,
    Emitter<NotificationsState> emit,
  ) async {
    if (event.accessToken.isEmpty) {
      emit(state.copyWith(isLoadingHistory: false, historyError: 'Sin sesión'));
      return;
    }

    emit(state.copyWith(isLoadingHistory: true, historyError: null));

    try {
      final remote = await _repository.fetchMyNotifications(
        accessToken: event.accessToken,
        horas: kNotificationWindowHours,
      );

      final incomingIds = remote.map((n) => n.id).toSet();
      final localOnly = state.notifications
          .where((n) => !incomingIds.contains(n.id))
          .where((n) => isNotificationWithinWindow(n.timestamp))
          .toList();

      final merged = [...localOnly, ...remote]
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

      emit(
        state.copyWith(
          notifications: merged,
          isLoadingHistory: false,
          historyError: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoadingHistory: false,
          historyError: 'No se pudo cargar el historial',
        ),
      );
    }
  }

  Future<void> _onMarkAsRead(
    NotificationsMarkAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      final updated = await _repository.markAsRead(
        accessToken: event.accessToken,
        notificationId: event.notificationId,
      );

      final list = state.notifications
          .map((n) => n.id == updated.id ? updated : n)
          .toList();

      emit(state.copyWith(notifications: list));
    } catch (_) {
      final list = state.notifications
          .map(
            (n) => n.id == event.notificationId ? n.copyWith(isRead: true) : n,
          )
          .toList();
      emit(state.copyWith(notifications: list));
    }
  }

  String get platformName => Platform.isIOS ? 'ios' : 'android';
}
