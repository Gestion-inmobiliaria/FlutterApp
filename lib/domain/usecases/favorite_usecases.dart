import 'package:inmobiliaria_app/domain/entities/property_entity.dart';
import 'package:inmobiliaria_app/domain/repository/favorite_repository.dart';

class AddToFavoritesUseCase {
  final FavoriteRepository repository;

  AddToFavoritesUseCase({required this.repository});

  Future<void> call(String propertyId, String token) {
    return repository.addToFavorites(propertyId, token);
  }
}

class RemoveFromFavoritesUseCase {
  final FavoriteRepository repository;

  RemoveFromFavoritesUseCase({required this.repository});

  Future<void> call(String propertyId, String token) {
    return repository.removeFromFavorites(propertyId, token);
  }
}

class GetFavoritesUseCase {
  final FavoriteRepository repository;

  GetFavoritesUseCase({required this.repository});

  Future<List<Property>> call(String token) {
    return repository.getFavorites(token);
  }
}

class GetFavoritesByRealStateUseCase {
  final FavoriteRepository repository;

  GetFavoritesByRealStateUseCase({required this.repository});

  Future<List<Property>> call(String realStateId, String token) {
    return repository.getFavoritesByRealState(realStateId, token);
  }
}

class CheckIsFavoriteUseCase {
  final FavoriteRepository repository;

  CheckIsFavoriteUseCase({required this.repository});

  Future<bool> call(String propertyId, String token) {
    return repository.checkIsFavorite(propertyId, token);
  }
} 