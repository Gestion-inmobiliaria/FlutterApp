import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:inmobiliaria_app/presentation/home/bloc/realstate_bloc.dart';
import 'package:inmobiliaria_app/presentation/home/bloc/realstate_event.dart';
import 'package:inmobiliaria_app/presentation/home/widgets/recommendation_section.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:inmobiliaria_app/presentation/home/widgets/visits_section.dart';
import 'package:inmobiliaria_app/presentation/visits/bloc/visitas_bloc.dart';

import '../widgets/custom_top_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String firstName = '';
  List<Map<String, dynamic>> inmobiliarias = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getUserName();
    fetchInmobiliarias();
  }

  Future<void> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final baseUrl = dotenv.env['URL_BACKEND']!;

    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/customer/checkToken?token=$token'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final fullName = body['data']['name'];
        setState(() {
          firstName = fullName;
        });
      } else {
        setState(() {
          firstName = 'Invitado';
        });
      }
    } catch (e) {
      debugPrint('Error al obtener nombre: $e');
      setState(() {
        firstName = 'Invitado';
      });
    }
  }

  final storage = FlutterSecureStorage();

  Future<void> fetchInmobiliarias() async {
    final baseUrl = dotenv.env['URL_BACKEND']!;
    final token = await storage.read(
      key: 'jwt',
    ); // Asegúrate que el token está guardado

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/realstate'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        setState(() {
          inmobiliarias = List<Map<String, dynamic>>.from(body['data']);
          isLoading = false;
        });
      } else {
        debugPrint('Error en fetchInmobiliarias: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error de red en fetchInmobiliarias: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTopHeader(
                        name: firstName,
                        onSearchChanged: (query) {
                          context.read<RealStateBloc>().add(
                            SearchRealStates(query),
                          );
                        },
                      ),
                      const RecommendationSection(),
                      BlocProvider(
                        create: (context) => VisitBloc()..add(LoadVisits()),
                        child: const VisitsSection(),
                      ),
                      const SizedBox(height: 80),
                      const SizedBox(
                        height: 80,
                      ), // ⬅️ Padding dinámico inferior
                    ],
                  ),
                ),
      ),
    );
  }
}
