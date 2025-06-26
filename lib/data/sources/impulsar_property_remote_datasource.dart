import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inmobiliaria_app/domain/entities/impulso_property.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImpulsoPropertyRemoteDatasource {
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

  // obtener todos los impulsos
  Future<List<ImpulsoProperty>> fetchImpulsos() async{
   try{
    final headers = await _getHeaders();
    debugPrint(
        'Obteniendo todos los impulsos - URL: $baseUrl/api/property',
      );
    final response= await http.get(
     Uri.parse('$baseUrl/api/impulsar_property'), 
     headers: headers);  

     if(response.statusCode == 200){
      final data = json.decode(response.body);
      return (data['data'] as List).map((e) => ImpulsoProperty.fromJson(e)).toList();
     }else if(response.statusCode==401){
      throw Exception(
          'No autorizado (401): Las credenciales no son válidas o han expirado',
      );
     }else{
      debugPrint(
          'Error fetchImpulsos: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Error al cargar impulsos (${response.statusCode})');
     }
    }catch(e){
     debugPrint('Excepción en fetchImpulsos: $e');
      throw Exception('Error de red o de formato');
    }
  }
}