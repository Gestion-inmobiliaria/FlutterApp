import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inmobiliaria_app/domain/entities/realstate_entity.dart'; // Ajusta el import real
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RealStateRemoteDatasource {
  final baseUrl = dotenv.env['URL_BACKEND']!;

  Future<List<RealState>> fetchRealStates() async {
    final response = await http.get(Uri.parse('$baseUrl/api/realstate'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List).map((e) => RealState.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar inmobiliarias');
    }
  }
}
