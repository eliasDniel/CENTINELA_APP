import '../../features/config/enviroment.dart';

/// Convierte `API_URL` (`http://host:3000/api`) en URL Socket.IO `/realtime`.
String buildRealtimeSocketUrl() {
  final api = Uri.parse(Enviroment.apiUrl);
  final path = api.path.replaceFirst(RegExp(r'/api/?$'), '');
  final portPart = api.hasPort ? ':${api.port}' : '';
  return '${api.scheme}://${api.host}$portPart$path/realtime';
}
