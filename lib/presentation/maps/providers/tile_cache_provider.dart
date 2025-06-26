import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_cache_hive_store/http_cache_hive_store.dart';
import 'package:inmobiliaria_app/presentation/maps/utils/tile_cache_service.dart';

/// Provider que expone el HiveCacheStore como Future
final tileCacheProvider = FutureProvider<HiveCacheStore>((ref) async {
  return TileCacheService.createStore();
});

/// Provider para limpiar el caché manualmente (útil desde un botón)
final clearTileCacheProvider = Provider((ref) {
  return TileCacheService.clearCache;
});

/// Provider para limpiar solo los tiles caducados
final cleanStaleTilesProvider = Provider((ref) {
  return TileCacheService.cleanStaleTiles;
});
