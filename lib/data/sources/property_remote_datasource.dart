import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inmobiliaria_app/domain/entities/property_entity.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PropertyRemoteDatasource {
  final baseUrl = dotenv.env['URL_BACKEND'];

  // Obtener el token de autenticación
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Construir headers con autenticación
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Obtener todas las propiedades
  Future<List<Property>> fetchProperties() async {
    try {
      final headers = await _getHeaders();
      debugPrint(
        'Obteniendo todas las propiedades - URL: $baseUrl/api/property',
      );
      final response = await http.get(
        Uri.parse('$baseUrl/api/property'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['data'] as List).map((e) => Property.fromJson(e)).toList();
      } else if (response.statusCode == 401) {
        throw Exception(
          'No autorizado (401): Las credenciales no son válidas o han expirado',
        );
      } else {
        debugPrint(
          'Error fetchProperties: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Error al cargar propiedades (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Exception en fetchProperties: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener propiedades por sector
  Future<List<Property>> fetchPropertiesBySector(String sectorId) async {
    try {
      final headers = await _getHeaders();
      debugPrint(
        'Obteniendo propiedades del sector: $sectorId - URL: $baseUrl/api/property?attr=sector.id&value=$sectorId',
      );
      final response = await http.get(
        Uri.parse('$baseUrl/api/property?attr=sector.id&value=$sectorId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint(
          'Propiedades del sector $sectorId: ${data['data']?.length ?? 0}',
        );
        return (data['data'] as List).map((e) => Property.fromJson(e)).toList();
      } else if (response.statusCode == 401) {
        throw Exception(
          'No autorizado (401): Las credenciales no son válidas o han expirado',
        );
      } else {
        debugPrint(
          'Error fetchPropertiesBySector: ${response.statusCode} - ${response.body}',
        );
        throw Exception(
          'Error al cargar propiedades del sector (${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('Exception en fetchPropertiesBySector: $e');
      throw Exception('Error al obtener propiedades del sector: $e');
    }
  }

  // Obtener propiedades por inmobiliaria para acceso público (cliente)
  Future<List<Property>> fetchPropertiesByRealState(String realStateId) async {
    try {
      final headers = await _getHeaders();
      debugPrint(
        'Obteniendo propiedades públicas de inmobiliaria: $realStateId',
      );

      // Primero intentamos obtener todos los sectores de la inmobiliaria
      final sectorsUri = Uri.parse('$baseUrl/api/sector');
      debugPrint('Obteniendo sectores: $sectorsUri');

      final sectorsResponse = await http.get(sectorsUri, headers: headers);

      if (sectorsResponse.statusCode == 200) {
        final sectorsData = jsonDecode(sectorsResponse.body);
        final sectors =
            (sectorsData['data'] as List)
                .where((sector) => sector['realState']?['id'] == realStateId)
                .toList();

        debugPrint(
          'Sectores encontrados para inmobiliaria $realStateId: ${sectors.length}',
        );

        if (sectors.isEmpty) {
          return []; // No hay sectores para esta inmobiliaria
        }

        // Recopilamos propiedades de todos los sectores de esta inmobiliaria
        List<Property> allProperties = [];

        for (var sector in sectors) {
          try {
            final sectorId = sector['id'];
            final propertiesUri = Uri.parse('$baseUrl/api/property');
            debugPrint('Obteniendo propiedades para sector $sectorId');

            final propertiesResponse = await http.get(
              propertiesUri,
              headers: headers,
            );

            if (propertiesResponse.statusCode == 200) {
              final propertiesData = jsonDecode(propertiesResponse.body);
              final sectorProperties =
                  (propertiesData['data'] as List)
                      .where(
                        (property) => property['sector']?['id'] == sectorId,
                      )
                      .map((p) => Property.fromJson(p))
                      .toList();

              debugPrint(
                'Propiedades encontradas para sector $sectorId: ${sectorProperties.length}',
              );
              allProperties.addAll(sectorProperties);
            }
          } catch (e) {
            debugPrint('Error obteniendo propiedades para sector: $e');
            // Continuamos con el siguiente sector
          }
        }

        debugPrint('Total propiedades encontradas: ${allProperties.length}');
        return allProperties;
      } else if (sectorsResponse.statusCode == 401) {
        // No estamos autorizados, error que será manejado por el Bloc
        debugPrint('No autorizado (401) al obtener sectores');
        throw Exception(
          'No autorizado (401): Las credenciales no son válidas o han expirado',
        );
      } else {
        throw Exception(
          'Error al cargar sectores (${sectorsResponse.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('Error general en fetchPropertiesByRealState: $e');
      // Propagamos el error para que lo maneje el Bloc
      throw e;
    }
  }

  // Obtener solo propiedades con ubicación (lat/lng) para una inmobiliaria
  Future<List<Property>> fetchPropertiesWithLocationByRealState(
    String realStateId,
  ) async {
    try {
      final headers = await _getHeaders();
      debugPrint(
        '📡 Obteniendo propiedades CON UBICACIÓN de inmobiliaria: $realStateId',
      );

      final sectorsUri = Uri.parse('$baseUrl/api/sector');
      final sectorsResponse = await http.get(sectorsUri, headers: headers);

      if (sectorsResponse.statusCode == 200) {
        final sectorsData = jsonDecode(sectorsResponse.body);
        final sectors =
            (sectorsData['data'] as List)
                .where((sector) => sector['realState']?['id'] == realStateId)
                .toList();

        final sectorIds = sectors.map((s) => s['id']).toSet();
        debugPrint('📍 Sector IDs de esta inmobiliaria: $sectorIds');

        if (sectorIds.isEmpty) {
          debugPrint('⚠️ No hay sectores asociados a esta inmobiliaria.');
          return [];
        }

        final propertiesUri = Uri.parse('$baseUrl/api/property');
        final propertiesResponse = await http.get(
          propertiesUri,
          headers: headers,
        );

        if (propertiesResponse.statusCode == 200) {
          final propertiesData = jsonDecode(propertiesResponse.body);
          final allProps = propertiesData['data'] as List;

          debugPrint('🔍 Total propiedades obtenidas: ${allProps.length}');

          int countWithUbicacion = 0;

          final filtered =
              allProps
                  .where((property) {
                    final desc = property['descripcion'];
                    final sectorId = property['sector']?['id'];
                    final u = property['ubicacion'];
                    final lat = u?['latitud'];
                    final lng = u?['longitud'];

                    final hasUbicacion =
                        u != null && lat != null && lng != null;
                    final isFromValidSector = sectorIds.contains(sectorId);
                    final shouldInclude = hasUbicacion && isFromValidSector;

                    debugPrint(
                      '➡ Eval: "$desc" | sectorId: $sectorId | lat: $lat | lng: $lng | include: $shouldInclude',
                    );

                    if (shouldInclude) countWithUbicacion++;
                    return shouldInclude;
                  })
                  .map((p) => Property.fromJson(p))
                  .toList();

          debugPrint(
            '✅ Propiedades con ubicación válidas: $countWithUbicacion',
          );
          return filtered;
        } else {
          throw Exception(
            '❌ Error al cargar propiedades (${propertiesResponse.statusCode})',
          );
        }
      } else {
        throw Exception(
          '❌ Error al cargar sectores (${sectorsResponse.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('💥 Error en fetchPropertiesWithLocationByRealState: $e');
      throw Exception('Error al obtener propiedades con ubicación: $e');
    }
  }

  // Obtener detalle de una propiedad
  Future<Property> fetchPropertyDetail(String propertyId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/property/$propertyId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Property.fromJson(data['data']);
      } else if (response.statusCode == 401) {
        throw Exception(
          'No autorizado (401): Las credenciales no son válidas o han expirado',
        );
      } else {
        debugPrint(
          'Error fetchPropertyDetail: ${response.statusCode} - ${response.body}',
        );
        throw Exception(
          'Error al cargar detalle de propiedad (${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('Exception en fetchPropertyDetail: $e');
      throw Exception('Error al obtener detalle de propiedad: $e');
    }
  }
}
