import 'dart:io';

import 'package:http_cache_hive_store/http_cache_hive_store.dart';
import 'package:path_provider/path_provider.dart';

class TileCacheService {
  static const String _boxName = 'tile_cache';

  /// Inicializa y retorna el HiveCacheStore para usar con flutter_map_cache
  static Future<HiveCacheStore> createStore() async {
    final dir = await getApplicationSupportDirectory();
    return HiveCacheStore(dir.path, hiveBoxName: _boxName);
  }

  /// Elimina completamente el contenido del caché
  static Future<void> clearCache() async {
    final store = await createStore();
    await store.clean(staleOnly: false);
  }

  /// Elimina solo tiles caducados (útil en segundo plano)
  static Future<void> cleanStaleTiles() async {
    final store = await createStore();
    await store.clean(staleOnly: true);
  }

  static Future<Directory> getCacheDirectory() async {
    return await getApplicationSupportDirectory();
  }
}
