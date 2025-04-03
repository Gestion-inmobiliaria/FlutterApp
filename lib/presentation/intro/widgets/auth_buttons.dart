import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/get_started_cubit.dart';

class AuthButtons extends StatelessWidget {
  const AuthButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () {
              print('[UI] Presionaste REGISTRARSE');
              context.read<GetStartedCubit>().navigateToRegister();
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: Colors.white,
            ),
            child: const Text(
              "Registrarse",
              style: TextStyle(color: Colors.black),
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () {
              print('[UI] Presionaste INICIAR SESIÓN');
              context.read<GetStartedCubit>().navigateToLogin();
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: Colors.green,
            ),
            child: const Text(
              "Iniciar Sesión",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}
