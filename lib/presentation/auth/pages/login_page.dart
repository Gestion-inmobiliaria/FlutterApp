import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inmobiliaria_app/presentation/auth/pages/sign_up_page.dart';
import 'package:inmobiliaria_app/presentation/home/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthLoading) {
            // puedes mostrar un loader si deseas
          } else if (state is AuthSuccess && context.mounted) {
            // ⬇️ Guardar token
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', state.token);

            // ⬇️ Redirige a HomePage
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Correo'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                      LoginRequested(
                        email: emailController.text,
                        password: passwordController.text,
                      ),
                    );
                  },
                  child:
                      state is AuthLoading
                          ? const CircularProgressIndicator()
                          : const Text('Ingresar'),
                ),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpPage()),
                    );
                  },
                  child: const Text('¿No tienes cuenta? Regístrate aquí'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
