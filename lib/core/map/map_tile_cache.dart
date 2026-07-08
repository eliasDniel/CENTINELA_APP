import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

const _mapStoreName = 'centinela_map_tiles';

/// Inicializa almacenamiento local de tiles (llamar una vez en [main]).
Future<void> initializeMapTileCache() async {
  try {
    await FMTCObjectBoxBackend().initialise();
    await const FMTCStore(_mapStoreName).manage.create();
  } catch (_) {
    // El store ya puede existir tras un reinicio de la app.
  }
}

/// Proveedor de tiles con caché en disco para mejor rendimiento offline/online.
TileProvider createCachedMapTileProvider() {
  return FMTCStore(_mapStoreName).getTileProvider(
    settings: FMTCTileProviderSettings(
      behavior: CacheBehavior.cacheFirst,
      cachedValidDuration: const Duration(days: 14),
    ),
  );
}
