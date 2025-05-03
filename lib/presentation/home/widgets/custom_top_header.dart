import 'package:flutter/material.dart';
import 'package:inmobiliaria_app/presentation/auth/pages/login_page.dart';
import 'package:inmobiliaria_app/presentation/profile/pages/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomTopHeader extends StatelessWidget {
  final String name;
  final ValueChanged<String> onSearchChanged;

  const CustomTopHeader({
    super.key,
    required this.name,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      color: const Color(0xFF3F6CDF),
      child: Stack(
        children: [
          // Greeting
          Positioned(
            left: 24,
            top: 68,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hola 👋',
                  style: TextStyle(
                    color: Color(0xFFCFDAF7),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                    letterSpacing: -0.24,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                    letterSpacing: 0.5,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          // Perfil con menú desplegable
          Positioned(
            right: 24,
            top: 72,
            child: PopupMenuButton<String>(
              offset: const Offset(0, 50),
              onSelected: (value) async {
                if (value == 'profile') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                } else if (value == 'logout') {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs
                      .clear(); // O solo eliminar el token si lo manejas así

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'profile',
                      child: Text('Ver perfil'),
                    ),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Text('Cerrar sesión'),
                    ),
                  ],
              icon: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Color(0xFF3F6CDF)),
              ),
            ),
          ),
          // Search box
          Positioned(
            left: 24,
            right: 24,
            top: 140,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x0716264E),
                    blurRadius: 20,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged:
                          onSearchChanged, // <- función pasada desde el padre
                      decoration: const InputDecoration(
                        hintText: 'Buscar inmobiliaria...',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
