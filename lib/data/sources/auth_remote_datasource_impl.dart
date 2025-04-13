import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_remote_datasource.dart';
import 'package:inmobiliaria_app/domain/entities/user_entity.dart';

// La clase `AuthRemoteDataSourceImpl` implementa la interfaz `AuthRemoteDataSource`.
// Su objetivo es realizar las operaciones de autenticación directamente con una API remota.

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  // Cliente HTTP utilizado para realizar las solicitudes a la API.
  final http.Client client;

  // Constructor que recibe una instancia de `http.Client`.
  // Esto permite inyectar un cliente HTTP, facilitando pruebas y mantenimiento.
  AuthRemoteDataSourceImpl({required this.client});

  @override
  // Método para iniciar sesión.
  // Este método realiza una solicitud POST a la API con las credenciales del usuario.
  Future<String> login(String email, String password) async {
    try {
      print('Enviando request al backend...');
      final response = await client.post(
        Uri.parse('http://192.168.0.6:3000/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      print('Respuesta: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        final token = body['data']['accessToken'];
        return token;
      } else {
        throw Exception('Error al iniciar sesión: ${response.body}');
      }
    } catch (e) {
      print('❌ ERROR al conectar con el backend: $e');
      rethrow;
    }
  }

  @override
  Future<void> register(UserEntity user) async {
    final url = Uri.parse('http://192.168.0.6:3000/api/auth/register');

    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'ci': user.ci,
        'name': user.name,
        'email': user.email,
        'password': user.password,
        'phone': user.phone,
        'address': user.address,
        'gender': user.gender,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      final message =
          jsonDecode(response.body)['message'] ?? 'Error desconocido';
      throw Exception('Registro fallido: $message');
    }
  }
}
