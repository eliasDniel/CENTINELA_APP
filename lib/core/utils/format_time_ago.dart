import 'package:intl/intl.dart';

/// Tiempo relativo legible para alertas y notificaciones.
String formatTimeAgo(DateTime timestamp) {
  final local = timestamp.isUtc ? timestamp.toLocal() : timestamp;
  final diff = DateTime.now().difference(local);

  if (diff.isNegative) return 'Hace unos segundos';

  final seconds = diff.inSeconds;
  if (seconds < 60) return 'Hace unos segundos';

  final minutes = diff.inMinutes;
  if (minutes < 60) return 'Hace $minutes min';

  final hours = diff.inHours;
  if (hours < 24) return 'Hace $hours h';

  final days = diff.inDays;
  if (days < 7) return days == 1 ? 'Hace 1 día' : 'Hace $days días';

  return DateFormat('d MMM, HH:mm', 'es').format(local);
}
