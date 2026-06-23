import 'package:centinela_milagro/features/auth/infrastructure/utils/auth_api_error_message.dart';

String reportApiErrorMessage(dynamic data, [String fallback = 'Error al procesar el reporte']) {
  return extractAuthApiErrorMessage(data) ?? fallback;
}
