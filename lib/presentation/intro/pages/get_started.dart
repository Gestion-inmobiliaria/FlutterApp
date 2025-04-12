import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inmobiliaria_app/core/configs/assets/app_images.dart';
import '../bloc/get_started_cubit.dart';
import '../bloc/get_started_state.dart';
import '../widgets/auth_buttons.dart';
import '../widgets/logo_intro.dart';
import 'package:inmobiliaria_app/presentation/auth/pages/login_page.dart';

// La clase `GetStartedPage` representa una pantalla de introducción que permite al usuario
// elegir entre registrarse o iniciar sesión. Utiliza Flutter Bloc para manejar la lógica
// de navegación basada en el estado.

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GetStartedCubit>(
      // Proporciona una instancia de `GetStartedCubit` para manejar la lógica de la pantalla.
      create: (_) => GetStartedCubit(),
      child: Builder(
        // El `Builder` se utiliza para obtener un nuevo `BuildContext` que ya tiene acceso al `BlocProvider`.
        builder: (context) {
          return BlocListener<GetStartedCubit, GetStartedState>(
            // Escucha los cambios en el estado del `GetStartedCubit`.
            listener: (context, state) {
              if (state is NavigateToLogin) {
                // Navega a la pantalla de inicio de sesión si el estado es `NavigateToLogin`.
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              } else if (state is NavigateToRegister) {
                // Navega a la pantalla de registro si el estado es `NavigateToRegister`.
                Navigator.pushNamed(context, '/register');
              }
            },
            child: Scaffold(
              // El `Scaffold` proporciona la estructura básica de la pantalla.
              body: Stack(
                children: [
                  // Fondo con una imagen de introducción.
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover, // La imagen cubre toda la pantalla.
                        image: AssetImage(
                          AppImages.IntroBG,
                        ), // Imagen definida en `AppImages`.
                      ),
                    ),
                  ),
                  // Contenido principal dentro de un área segura.
                  SafeArea(
                    child: Column(
                      children: [
                        // Espacio expandido para centrar el logo en la pantalla.
                        const LogoIntro(),
                        const AuthButtons(),
                        const SizedBox(height: 20), // Espaciado inferior.
                      ],
                    ),
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
