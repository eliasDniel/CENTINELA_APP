// RF-0307: modelo de notificación push para la app ciudadana

enum NotificationType {
  alertaSeguridad,
  alertaHidrica,
  emergencia,
  reporteEstado,
  suscripcion,
  sistema,
}

enum NotificationLevel {
  vigilancia,
  alerta,
  emergencia,
}

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.barrio,
    required this.type,
    required this.timestamp,
    this.level,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final String barrio;
  final NotificationType type;
  final NotificationLevel? level;
  final DateTime timestamp;
  final bool isRead;

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      barrio: barrio,
      type: type,
      level: level,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
