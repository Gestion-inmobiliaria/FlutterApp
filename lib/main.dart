import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:inmobiliaria_app/core/configs/theme/app_theme.dart';
import 'package:inmobiliaria_app/data/sources/property_remote_datasource.dart';
import 'package:inmobiliaria_app/presentation/auth/bloc/auth_bloc.dart';
import 'package:inmobiliaria_app/presentation/home/bloc/realstate_bloc.dart';
import 'package:inmobiliaria_app/data/sources/realstate_remote_datasource.dart';
import 'package:inmobiliaria_app/presentation/home/bloc/realstate_event.dart';
import 'package:inmobiliaria_app/presentation/splash/pages/splash.dart';
import 'service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Error cargando .env: $e - usando valores por defecto");
    // Si no se puede cargar el archivo .env, intentamos con .envExample
    try {
      await dotenv.load(fileName: ".envExample");
    } catch (e) {
      debugPrint("Error cargando .envExample: $e");
    }
  }
  
  setupLocator();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<RealStateBloc>(
          create:
              (_) =>
                  RealStateBloc(RealStateRemoteDatasource())
                    ..add(LoadRealStates()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightheme,
      debugShowCheckedModeBanner: false,
      home: const SplashPage(),
    );
  }
}
