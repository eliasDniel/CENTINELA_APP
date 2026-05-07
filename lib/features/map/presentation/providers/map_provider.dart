// RF-0306: Map providers
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/map_marker_entity.dart';
import '../../domain/repositories/map_repository.dart';
import '../../domain/usecases/get_map_markers_usecase.dart';
import '../../infrastructure/datasources/map_local_datasource.dart';
import '../../infrastructure/repositories/map_repository_impl.dart';

final mapRepositoryProvider = Provider<MapRepository>((ref) {
  final dataSource = MapLocalDataSource();
  return MapRepositoryImpl(dataSource);
});

final mapMarkersProvider = FutureProvider<List<MapMarkerEntity>>((ref) async {
  final repository = ref.watch(mapRepositoryProvider);
  final usecase = GetMapMarkersUseCase(repository);
  return usecase();
});
