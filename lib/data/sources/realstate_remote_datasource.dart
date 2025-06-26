import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inmobiliaria_app/domain/entities/realstate_entity.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RealStateRemoteDatasource {
  final baseUrl = dotenv.env['URL_BACKEND']!;
  final storage = FlutterSecureStorage();

  Future<List<RealState>> fetchRealStates() async {
    final token = await storage.read(key: 'jwt');

    final response = await http.get(
      Uri.parse('$baseUrl/api/realstate'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List).map((e) => RealState.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar inmobiliarias: ${response.statusCode}');
    }
  }
}
