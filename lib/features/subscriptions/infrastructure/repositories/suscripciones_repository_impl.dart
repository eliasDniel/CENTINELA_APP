import 'package:centinela_milagro/features/auth/domain/entities/zona_entity.dart';
import 'package:centinela_milagro/features/map/domain/entities/user_zona_entity.dart';

import '../../domain/datasources/suscripciones_datasources.dart';
import '../../domain/repository/suscripciones_repository.dart';

class SuscripcionesRepositoryImpl implements SuscripcionesRepository {
  final SuscripcionesDatasource datasource;

  SuscripcionesRepositoryImpl({required this.datasource});

  @override
  Future<List<ZonaEntity>> getAllZonas() => datasource.getAllZonas();

  @override
  Future<List<UserZonaEntity>> getMyZonas() => datasource.getMyZonas();

  @override
  Future<bool> setPrincipalZona(String zonaId) =>
      datasource.setPrincipalZona(zonaId);

  @override
  Future<bool> subscribeToZona(String zonaId) =>
      datasource.subscribeToZona(zonaId);

  @override
  Future<bool> unsubscribeFromZona(String zonaId) =>
      datasource.unsubscribeFromZona(zonaId);
}
