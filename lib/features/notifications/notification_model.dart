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
    this.alertaId,
  });

  final String id;
  final String title;
  final String body;
  final String barrio;
  final NotificationType type;
  final NotificationLevel? level;
  final DateTime timestamp;
  final bool isRead;
  final String? alertaId;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      barrio: json['zona']?.toString() ??
          json['barrio']?.toString() ??
          'Sin zona',
      type: _parseType(json['type']?.toString()),
      level: _parseLevel(json['level']?.toString()),
      timestamp: _parseTimestamp(json['timestamp']),
      isRead: json['isRead'] == true,
      alertaId: json['alertaId']?.toString(),
    );
  }

  factory NotificationModel.fromPushData(Map<String, dynamic> data) {
    return NotificationModel(
      id: data['id']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      body: data['body']?.toString() ?? '',
      barrio: data['zona']?.toString() ??
          data['barrio']?.toString() ??
          'Sin zona',
      type: _parseType(data['type']?.toString()),
      level: _parseLevel(data['level']?.toString()),
      timestamp: _parseTimestamp(data['timestamp']),
      isRead: data['isRead'] == true || data['isRead']?.toString() == 'true',
      alertaId: data['alertaId']?.toString(),
    );
  }

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
      alertaId: alertaId,
    );
  }

  static NotificationType _parseType(String? raw) {
    final normalized = (raw ?? '').toLowerCase().replaceAll('_', '');

    if (normalized.contains('sos') ||
        normalized == 'panico' ||
        normalized.contains('secuestro') ||
        normalized.contains('homicidio')) {
      return NotificationType.emergencia;
    }
    if (normalized == 'reporteciudadano' || normalized == 'reporteestado') {
      return NotificationType.reporteEstado;
    }
    if (normalized.contains('hidric') || normalized.contains('agua')) {
      return NotificationType.alertaHidrica;
    }
    if (normalized == 'suscripcion') {
      return NotificationType.suscripcion;
    }
    if (normalized == 'sistema') {
      return NotificationType.sistema;
    }

    return NotificationType.alertaSeguridad;
  }

  static NotificationLevel? _parseLevel(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return switch (raw) {
      'emergencia' => NotificationLevel.emergencia,
      'alerta' => NotificationLevel.alerta,
      'vigilancia' => NotificationLevel.vigilancia,
      _ => null,
    };
  }

  static DateTime _parseTimestamp(dynamic raw) {
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
