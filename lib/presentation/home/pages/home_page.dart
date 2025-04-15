import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:inmobiliaria_app/presentation/profile/pages/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inmobiliaria_app/presentation/auth/pages/login_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String firstName = '';

  @override
  void initState() {
    super.initState();
    getUserName();
  }

  Future<void> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final baseUrl = dotenv.env['URL_BACKEND']!;
    print('🔐 Token enviado: $token');

    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/checkToken?token=$token'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final fullName =
            body['data']['name']; // ✅ accede a 'name' dentro de 'data'

        setState(() {
          firstName = fullName.split(' ').first;
        });
      } else {
        setState(() {
          firstName = 'Invitado';
        });
      }
    } catch (e) {
      debugPrint('❌ Error al obtener nombre: $e');
      setState(() {
        firstName = 'Invitado';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          PopupMenuButton<String>(
            offset: const Offset(0, 40),
            onSelected: (value) async {
              if (value == 'perfil') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              } else if (value == 'logout') {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('token');
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'perfil',
                    child: Text('Ver perfil'),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Text('Cerrar sesión'),
                  ),
                ],
            child: Row(
              children: [
                const Icon(Icons.person),
                const SizedBox(width: 4),
                Text(
                  firstName.isNotEmpty ? firstName : '',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const Icon(Icons.arrow_drop_down),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ],
      ),
      body: const Center(child: Text('Bienvenido al sistema')),
    );
  }
}
