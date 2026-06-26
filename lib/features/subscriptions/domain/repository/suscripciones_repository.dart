import 'package:centinela_milagro/features/auth/domain/entities/zona_entity.dart';
import 'package:centinela_milagro/features/map/domain/entities/user_zona_entity.dart';

abstract class SuscripcionesRepository {
  Future<List<ZonaEntity>> getAllZonas();

  Future<List<UserZonaEntity>> getMyZonas();

  Future<bool> setPrincipalZona(String zonaId);

  Future<bool> subscribeToZona(String zonaId);

  Future<bool> unsubscribeFromZona(String zonaId);
}
