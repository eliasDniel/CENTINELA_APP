import 'package:flutter_riverpod/legacy.dart';

/// Reporte SOS enviado; se enlaza con la alerta cuando llega por WebSocket.
final pendingSosReportIdProvider = StateProvider<String?>((ref) => null);
