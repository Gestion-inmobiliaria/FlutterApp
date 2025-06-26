import 'package:inmobiliaria_app/domain/entities/property_entity.dart';

abstract class FavoriteRepository {
  Future<void> addToFavorites(String propertyId, String token);
  Future<void> removeFromFavorites(String propertyId, String token);
  Future<List<Property>> getFavorites(String token);
  Future<List<Property>> getFavoritesByRealState(String realStateId, String token);
  Future<bool> checkIsFavorite(String propertyId, String token);
} 