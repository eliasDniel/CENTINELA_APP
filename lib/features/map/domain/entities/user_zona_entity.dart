import 'alert_zona_entity.dart';

class UserZonaEntity {
  final String zonaId;
  final String tipo;
  final AlertZonaEntity zona;

  const UserZonaEntity({
    required this.zonaId,
    required this.tipo,
    required this.zona,
  });

  bool get isPrincipal => tipo == 'principal';
}
