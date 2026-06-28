import 'package:centinela_milagro/core/notifications/notification_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsEnabledNotifier extends Notifier<bool> {
  @override
  bool build() => NotificationPreferences.enabled;

  Future<void> setEnabled(bool value) async {
    await NotificationPreferences.setEnabled(value);
    state = value;
  }

  Future<void> reload() async {
    await NotificationPreferences.load();
    state = NotificationPreferences.enabled;
  }
}

final notificationsEnabledProvider =
    NotifierProvider<NotificationsEnabledNotifier, bool>(
  NotificationsEnabledNotifier.new,
);
