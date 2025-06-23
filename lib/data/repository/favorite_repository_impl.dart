import 'package:inmobiliaria_app/data/sources/favorite_remote_datasource.dart';
import 'package:inmobiliaria_app/domain/entities/property_entity.dart';
import 'package:inmobiliaria_app/domain/repository/favorite_repository.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteRemoteDataSource remoteDataSource;

  FavoriteRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> addToFavorites(String propertyId, String token) async {
    try {
      await remoteDataSource.addToFavorites(propertyId, token);
    } catch (e) {
      throw Exception('Error al agregar a favoritos: $e');
    }
  }

  @override
  Future<void> removeFromFavorites(String propertyId, String token) async {
    try {
      await remoteDataSource.removeFromFavorites(propertyId, token);
    } catch (e) {
      throw Exception('Error al remover de favoritos: $e');
    }
  }

  @override
  Future<List<Property>> getFavorites(String token) async {
    try {
      return await remoteDataSource.getFavorites(token);
    } catch (e) {
      throw Exception('Error al obtener favoritos: $e');
    }
  }

  @override
  Future<List<Property>> getFavoritesByRealState(String realStateId, String token) async {
    try {
      return await remoteDataSource.getFavoritesByRealState(realStateId, token);
    } catch (e) {
      throw Exception('Error al obtener favoritos de la inmobiliaria: $e');
    }
  }

  @override
  Future<bool> checkIsFavorite(String propertyId, String token) async {
    try {
      return await remoteDataSource.checkIsFavorite(propertyId, token);
    } catch (e) {
      return false;
    }
  }
} 