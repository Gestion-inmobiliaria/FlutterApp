import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inmobiliaria_app/data/sources/realstate_remote_datasource.dart';
import 'package:inmobiliaria_app/presentation/home/bloc/realstate_bloc.dart';
import 'package:inmobiliaria_app/presentation/home/bloc/realstate_event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inmobiliaria_app/presentation/home/pages/home_page.dart';
import 'package:inmobiliaria_app/core/configs/assets/app_vectors.dart';
import 'package:inmobiliaria_app/presentation/intro/pages/get_started.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// La clase `SplashPage` representa una pantalla de carga inicial (splash screen)
// que se muestra al iniciar la aplicación. Es un widget con estado (`StatefulWidget`)
// que redirige automáticamente a otra pantalla después de un breve retraso.

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  @override
  void initState() {
    super.initState();
    // Llama a la función `redirect` para redirigir a otra pantalla después de un retraso.
    redirect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El widget `Scaffold` proporciona la estructura básica de la pantalla.
      body: Center(
        // Muestra el logo de la aplicación utilizando un archivo SVG.
        child: SvgPicture.asset(AppVectors.logo),
      ),
    );
  }

  // La función `redirect` espera 2 segundos y luego redirige a la pantalla `GetStartedPage`.
  Future<void> redirect() async {
    await Future.delayed(const Duration(seconds: 2));

    final token = await secureStorage.read(key: 'jwt');

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create:
                    (_) =>
                        RealStateBloc(RealStateRemoteDatasource())
                          ..add(LoadRealStates()),
                child: const HomePage(),
              ),
        ),
        (route) => false,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GetStartedPage()),
      );
    }
  }
}
