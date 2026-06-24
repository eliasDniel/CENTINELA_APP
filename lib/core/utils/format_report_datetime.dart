import 'package:intl/intl.dart';

/// Formatea fechas ISO del backend para mostrar en reportes.
String formatReportDateTime(String iso) {
  final parsed = DateTime.tryParse(iso);
  if (parsed == null) return iso;
  final local = parsed.toLocal();
  return DateFormat("d MMM yyyy, HH:mm", 'es').format(local);
}
