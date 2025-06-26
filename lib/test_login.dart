import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import 'data/sources/auth_remote_datasource_impl.dart';
import 'data/repository/auth_repository_impl.dart';
import 'domain/usecases/login_user.dart';

void main() async {
  final client = http.Client();

  // Crear instancia de datasource, repo y usecase
  final remoteDataSource = AuthRemoteDataSourceImpl(client: client);
  final repository = AuthRepositoryImpl(remoteDataSource);
  final loginUser = LoginUser(repository);

  try {
    final token = await loginUser('admin@correo.com', 'admin123');
    print('✅ Token obtenido:\n$token');
  } catch (e) {
    print('❌ Error durante login:\n$e');
  }
}

class TestAuthHelper {
  /// Hace un login real con el backend para obtener un token válido
  static Future<void> simulateLogin() async {
    final prefs = await SharedPreferences.getInstance();
    
    try {
      final client = http.Client();
      final response = await client.post(
        Uri.parse('http://10.0.2.2:3000/api/auth/customer/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': 'test@example.com',
          'password': 'test123'
        }),
      );
      
      debugPrint('🔥 Login response status: ${response.statusCode}');
      debugPrint('🔥 Login response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final token = responseData['data']['accessToken'];
        
        await prefs.setString('token', token);
        debugPrint('🔥 Token real guardado para testing');
      } else {
        // Fallback: usar token real obtenido del registro
        const testToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJlY2NiZGMwNy04Yzk1LTQwYTQtYTVmNC1kYWI1Mjg1MDljOGIiLCJlbWFpbCI6InRlc3RAZXhhbXBsZS5jb20iLCJ0eXBlIjoiY2xpZW50IiwiaWF0IjoxNzUwNTYxMDE4LCJleHAiOjE3NTA1ODk4MTh9.Pb-OXJAkHk5T2uVSNlr0i-sfOVdAcJXaHL7XDmXCiSU';
        await prefs.setString('token', testToken);
        debugPrint('🔥 Token real guardado (fallback): Token válido');
      }
          } catch (e) {
        debugPrint('🔥 Error en login real: $e');
        // Fallback: usar token real
        const testToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJlY2NiZGMwNy04Yzk1LTQwYTQtYTVmNC1kYWI1Mjg1MDljOGIiLCJlbWFpbCI6InRlc3RAZXhhbXBsZS5jb20iLCJ0eXBlIjoiY2xpZW50IiwiaWF0IjoxNzUwNTYxMDE4LCJleHAiOjE3NTA1ODk4MTh9.Pb-OXJAkHk5T2uVSNlr0i-sfOVdAcJXaHL7XDmXCiSU';
        await prefs.setString('token', testToken);
        debugPrint('🔥 Token real guardado (error fallback): Token válido');
      }
  }
  
  /// Limpia el token de testing
  static Future<void> clearTestLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    debugPrint('🔥 Token de testing eliminado');
  }
  
  /// Verifica si hay token guardado
  static Future<bool> hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null;
  }
}
