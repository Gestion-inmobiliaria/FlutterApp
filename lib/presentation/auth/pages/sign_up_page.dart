import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inmobiliaria_app/domain/entities/user_entity.dart';
import 'package:inmobiliaria_app/presentation/auth/bloc/auth_bloc.dart';
import 'package:inmobiliaria_app/presentation/auth/bloc/auth_event.dart';
import 'package:inmobiliaria_app/presentation/auth/bloc/auth_state.dart';
import 'package:inmobiliaria_app/presentation/home/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final ciController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  String gender = 'masculino';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthSuccess) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', state.token);

            Navigator.pushReplacement(
              context,
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
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: ciController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'CI'),
                    validator:
                        (value) => value!.isEmpty ? 'Campo requerido' : null,
                  ),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator:
                        (value) => value!.isEmpty ? 'Campo requerido' : null,
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Correo'),
                    validator:
                        (value) =>
                            value!.contains('@') ? null : 'Correo inválido',
                  ),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                    obscureText: true,
                    validator:
                        (value) =>
                            value!.length < 6 ? 'Mínimo 6 caracteres' : null,
                  ),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Teléfono'),
                  ),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Dirección'),
                  ),
                  DropdownButtonFormField<String>(
                    value: gender,
                    items:
                        ['masculino', 'femenino', 'otro']
                            .map(
                              (g) => DropdownMenuItem(value: g, child: Text(g)),
                            )
                            .toList(),
                    onChanged: (value) => setState(() => gender = value!),
                    decoration: const InputDecoration(labelText: 'Género'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed:
                        state is AuthLoading
                            ? null // 🔒 Desactivar el botón mientras se carga
                            : () {
                              if (_formKey.currentState!.validate()) {
                                final user = UserEntity(
                                  ci: int.parse(ciController.text),
                                  name: nameController.text,
                                  email: emailController.text,
                                  password: passwordController.text,
                                  phone: phoneController.text,
                                  address: addressController.text,
                                  gender: gender,
                                );

                                context.read<AuthBloc>().add(
                                  SignUpRequested(user),
                                );
                              }
                            },
                    child:
                        state is AuthLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text('Registrarse'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
