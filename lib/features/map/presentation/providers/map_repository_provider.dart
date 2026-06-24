import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/services/key_value_storage_impl.dart';
import '../../domain/repositories/map_repository.dart';
import '../../infrastructure/datasources/map_datasource_impl.dart';
import '../../infrastructure/repositories/map_repository_impl.dart';

final mapRepositoryProvider = Provider<MapRepository>((ref) {
  return MapRepositoryImpl(
    datasources: MapDatasourceImpl(
      keyValueStorageService: KeyValueStorageImpl(),
    ),
  );
});
