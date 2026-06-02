// RF-0307: recibir o no notificaciones push (prototipo)
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsEnabledNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void setEnabled(bool value) => state = value;
}

final notificationsEnabledProvider =
    NotifierProvider<NotificationsEnabledNotifier, bool>(
  NotificationsEnabledNotifier.new,
);
