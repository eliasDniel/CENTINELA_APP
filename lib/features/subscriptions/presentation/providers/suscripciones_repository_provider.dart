import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/services/key_value_storage_impl.dart';
import '../../domain/repository/suscripciones_repository.dart';
import '../../infrastructure/datasources/suscripciones_datasources_impl.dart';
import '../../infrastructure/repositories/suscripciones_repository_impl.dart';

final suscripcionesRepositoryProvider = Provider<SuscripcionesRepository>((ref) {
  return SuscripcionesRepositoryImpl(
    datasource: SuscripcionesDatasourcesImpl(
      keyValueStorageService: KeyValueStorageImpl(),
    ),
  );
});
