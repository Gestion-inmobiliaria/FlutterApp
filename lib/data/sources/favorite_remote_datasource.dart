import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inmobiliaria_app/domain/entities/property_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class FavoriteRemoteDataSource {
  Future<void> addToFavorites(String propertyId, String token);
  Future<void> removeFromFavorites(String propertyId, String token);
  Future<List<Property>> getFavorites(String token);
  Future<List<Property>> getFavoritesByRealState(String realStateId, String token);
  Future<bool> checkIsFavorite(String propertyId, String token);
}

class FavoriteRemoteDataSourceImpl implements FavoriteRemoteDataSource {
  final http.Client client;
  final baseUrl = dotenv.env['URL_BACKEND'];

  FavoriteRemoteDataSourceImpl({required this.client});

  @override
  Future<void> addToFavorites(String propertyId, String token) async {
    debugPrint('🔥 Intentando agregar a favoritos - PropertyId: $propertyId');
    debugPrint('🔥 Token: ${token.isNotEmpty ? "Presente" : "Ausente"}');
    debugPrint('🔥 URL completa: $baseUrl/api/favorites');
    
    final response = await client.post(
      Uri.parse('$baseUrl/api/favorites'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'propertyId': propertyId}),
    );

    debugPrint('🔥 Respuesta agregar favorito - Status: ${response.statusCode}');
    debugPrint('🔥 Respuesta agregar favorito - Body: ${response.body}');

    if (response.statusCode != 201) {
      throw Exception('Error al agregar a favoritos: ${response.body}');
    }
  }

  @override
  Future<void> removeFromFavorites(String propertyId, String token) async {
    debugPrint('🔥 Intentando remover de favoritos - PropertyId: $propertyId');
    debugPrint('🔥 Token: ${token.isNotEmpty ? "Presente" : "Ausente"}');
    
    final response = await client.delete(
      Uri.parse('$baseUrl/api/favorites'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'propertyId': propertyId}),
    );

    debugPrint('🔥 Respuesta remover favorito - Status: ${response.statusCode}');
    debugPrint('🔥 Respuesta remover favorito - Body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Error al remover de favoritos: ${response.body}');
    }
  }

  @override
  Future<List<Property>> getFavorites(String token) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/favorites'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> favoritesJson = json.decode(response.body);
      return favoritesJson
          .map((favoriteJson) => Property.fromJson(favoriteJson['property']))
          .toList();
    } else {
      throw Exception('Error al obtener favoritos: ${response.body}');
    }
  }

  @override
  Future<List<Property>> getFavoritesByRealState(String realStateId, String token) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/favorites/by-realstate/$realStateId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> favoritesJson = json.decode(response.body);
      return favoritesJson
          .map((favoriteJson) => Property.fromJson(favoriteJson['property']))
          .toList();
    } else {
      throw Exception('Error al obtener favoritos de la inmobiliaria: ${response.body}');
    }
  }

  @override
  Future<bool> checkIsFavorite(String propertyId, String token) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/favorites/check/$propertyId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseJson = json.decode(response.body);
      return responseJson['isFavorite'] ?? false;
    } else {
      return false;
    }
  }
} 