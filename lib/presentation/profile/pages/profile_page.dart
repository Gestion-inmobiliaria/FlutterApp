import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  String ci = '';
  String name = '';
  String email = '';
  String phone = '';
  String gender = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final baseUrl = dotenv.env['URL_BACKEND']!;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/checkToken?token=$token'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        setState(() {
          ci = data['ci'].toString();
          name = data['name'];
          email = data['email'];
          phone = data['phone'] ?? '';
          gender = data['gender'] ?? '';
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error cargando perfil: $e');
    }
  }

  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    // TODO: Enviar cambios al backend
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil actualizado correctamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Información del perfil',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildField(
                            label: 'CI',
                            initialValue: ci,
                            enabled: false,
                          ),
                          _buildField(
                            label: 'Nombre',
                            initialValue: name,
                            onChanged: (val) => name = val,
                          ),
                          _buildField(
                            label: 'Email',
                            initialValue: email,
                            onChanged: (val) => email = val,
                          ),
                          _buildField(
                            label: 'Teléfono',
                            initialValue: phone,
                            onChanged: (val) => phone = val,
                          ),
                          _buildField(
                            label: 'Género',
                            initialValue: gender,
                            onChanged: (val) => gender = val,
                          ),
                          const SizedBox(height: 32),
                          SizedBox(width: double.infinity),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildField({
    required String label,
    required String initialValue,
    bool enabled = true,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: initialValue,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey.shade200,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
